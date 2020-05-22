#
# NaPiRE trouble predictor
# Copyright (C) 2019, TU Berlin, ASET, Florian Wiesweg
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

module napire

    using DataFrames
    using Printf

    import BayesNets
    import Distributed
    import Random
    import SharedArrays

    include("graphviz.jl")
    export graphviz

    function __analyse_module_content(dict, mod, filter)
        for n in names(mod; all = true)
            if !isdefined(mod, n)
                continue
            end

            f = getfield(mod, n)
            if !startswith(string(n), "__",) && filter(n, f)
                dict[string(mod) * "." * string(n)] = f
            end
        end
        return dict
    end

    include("datasets.jl")
    include("metrics.jl")

    const inference_methods = __analyse_module_content(Dict{String, Type}(), BayesNets,
                    (n, f) -> isa(f, Type) && f != BayesNets.InferenceMethod && f <: BayesNets.InferenceMethod)
    const datasets = __analyse_module_content(Dict{String, Function}(), napire.DataSets,
                    (n, f) -> isa(f, Function) && n != :eval && n != :include)
    const metrics = __analyse_module_content(Dict{String, Function}(), napire.Metrics,
                    (n, f) -> isa(f, Function) && n != :eval && n != :include)
    const models = Dict(string(:bayesnet) => nothing, string(:independent) => nothing)

    const default_inference_method = inference_methods["BayesNets.GibbsSamplingNodewise"]
    const default_dataset = datasets["napire.DataSets.nap_2014"]
    const default_model = string(:bayesnet)
    const default_baseline_model = string(:independent)

    export inference_methods, datasets, metrics, default_inference_method, default_dataset

    include("napireweb.jl")
    export napireweb

    function load(dataset, args...; summary = false)
        data = datasets[string(dataset)](args...)

        #
        # summary
        #
        if summary
            println("Nodes: ", length(data.nodes))
            println("Descriptions: ", length(data.descriptions))
            println("Edges: ", length(data.edges))
            println("Samples: ", size(data.data)[1])

            for node in data.nodes
                parents = length([ g for g in keys(data.edges) if g.second == node])
                if parents > 0
                    println(string(node) * " parents: " * lpad(string(parents), 2, ' '), " configurations: " * string(2^parents))
                end
            end
        end

        return data
    end

    function plot(data, output_type = graphviz.default_output_type; shape = shape(n) = "ellipse", penwidth_factor = 5, ranksep = 3, label = identity)
        graph_layout = data.edges
        graph = graphviz.Dot(data.nodes, keys(graph_layout))

        for node in data.nodes
            graphviz.set(graph, node, graphviz.NodeProps.label, label(node))
            graphviz.set(graph, node, graphviz.NodeProps.margin, 0)
            graphviz.set(graph, node, graphviz.NodeProps.fillcolor, "white")
            graphviz.set(graph, node, graphviz.NodeProps.style, "filled")
            graphviz.set(graph, node, graphviz.NodeProps.shape, shape(node))
            if haskey(data.descriptions, node)
                graphviz.set(graph, node, graphviz.NodeProps.tooltip, data.descriptions[node])
            end
        end

        graphviz.set(graph, graphviz.GraphProps.ranksep, ranksep)

        max_edges = isempty(graph_layout) ? 0 : maximum(values(graph_layout))

        for ((n1, n2), n_edges) in graph_layout
            edge_weight = n_edges / max_edges
            alpha = @sprintf("%02x", round(edge_weight * 255))

            graphviz.set(graph, (n1 => n2), graphviz.EdgeProps.color, "#000000$(alpha)")
            graphviz.set(graph, (n1 => n2), graphviz.EdgeProps.penwidth, edge_weight * penwidth_factor)
            graphviz.set(graph, (n1 => n2), graphviz.EdgeProps.tooltip, data.descriptions[n1] * "\n ---> \n" * data.descriptions[n2])
        end

        graphviz.plot(graph, output_type)
    end
    export plot

    function train(data, model::Val{:bayesnet}, subsample = nothing)
        # extract graph layout
        graph_layout = Tuple(keys(data.edges))
        graph_data = subsample != nothing ? data.data[subsample,:] : data.data

        if size(graph_data, 2) > 0
            # remove completely empty lines, BayesNets does not like them
            graph_data = graph_data[sum(convert(Matrix, graph_data), dims = 2)[:] .> 0, :]
        end

        # add one, BayesNets expects state labelling to be 1-based
        graph_data = DataFrame(colwise(x -> convert(Array{Int64}, x) .+ 1, data.data), names(data.data))

        return BayesNets.fit(BayesNets.DiscreteBayesNet, graph_data, graph_layout)
    end
    export bayesian_train

    function train(data, model::Val{:independent}, subsample = nothing)
        graph_data = subsample != nothing ? data.data[subsample,:] : data.data
        return Dict( k => v for (k, v) in zip(names(graph_data), colwise(x -> sum(x), graph_data) / size(graph_data, 1)) )
    end
    export independent_train

    function predict(model, inference_method::String, query, evidence)
        return predict(model, inference_methods[inference_method], query, evidence)
    end

    function predict(independent_model::AbstractDict{Symbol,Float64}, inference_method::Type, query::Set{Symbol}, evidence::Dict{Symbol, Bool})
        return Dict(symbol => independent_model[symbol] for symbol in query)
    end

    function predict(bn::BayesNets.DiscreteBayesNet, inference_method::Type, query::Set{Symbol}, evidence::Dict{Symbol, Bool})
        evidence = Dict{Symbol, Any}( kv.first => convert(Int8, kv.second) + 1 for kv in evidence)

        f = BayesNets.infer(inference_method(), bn, collect(query), evidence = evidence)
        results = Dict{Symbol, Float64}()
        for symbol in query
            results[symbol] = sum(f[BayesNets.Assignment(symbol => 2)].potential)
        end

        return results
    end
    export predict

    function plot_architecture(dataset, node_types::Array{Pair{Symbol, Symbol}}, output_type = graphviz.default_output_type; shorten = true, shape = shape(n) = "ellipse", ranksep = 1, rankdir = "LR", kwargs...)
        data = load(dataset, Array{Tuple{Symbol,Bool,UInt64,Bool}, 1}(undef, 0), [ (nt.first, nt.second, false, convert(UInt64, 0)) for nt in node_types ])
        graph = graphviz.Dot([], node_types)

        for node in graph.nodes
            println(split(string(node), "_"))
            label = shorten ? join([ sn[1] for sn in split(string(node), "_") if sn != "CODE" ]) : string(node)

            graphviz.set(graph, node, graphviz.NodeProps.label, label)
            graphviz.set(graph, node, graphviz.NodeProps.margin, 0)
            graphviz.set(graph, node, graphviz.NodeProps.fillcolor, "white")
            graphviz.set(graph, node, graphviz.NodeProps.style, "filled")
            graphviz.set(graph, node, graphviz.NodeProps.shape, shape(node))
        end
        graphviz.set(graph, graphviz.GraphProps.ranksep, ranksep)
        graphviz.set(graph, graphviz.GraphProps.rankdir, rankdir)

        graphviz.plot(graph, output_type)
    end

    function plot_prediction(data, query, evidence, results, output_type = graphviz.default_output_type; half_cell_width = 40, shorten = true, kwargs...)
        function label(node)
            plot_label(n) = shorten ? join([ sn[1] for sn in split(string(n), "_")[1:end-1] if sn != "CODE" ]) * string(n)[end - 2:end] : n

            if !in(node, query) && !haskey(evidence, node) && !haskey(results, node)
                return plot_label(node)
            end

            padding = (haskey(results, node) || haskey(evidence, node)) ? 1 : 5

            label = """< <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">"""
            label *= """<TR><TD COLSPAN="2" CELLPADDING="$(padding)">$(plot_label(node))</TD></TR>"""
            if haskey(results, node)
                false_val = @sprintf("%d", round( (1 - results[node]) * 100))
                true_val = @sprintf("%d", round(results[node] * 100))
                label *= """<TR><TD WIDTH="$half_cell_width">$(false_val)%</TD><TD WIDTH="$half_cell_width">$(true_val)%</TD></TR>"""
            end

            if haskey(evidence, node)
                false_color = evidence[node] ? "white" : "grey"
                true_color = evidence[node] ? "grey" : "white"
                label *= """<TR><TD WIDTH="$half_cell_width" BGCOLOR="$false_color">  </TD><TD WIDTH="$half_cell_width" BGCOLOR="$true_color">  </TD></TR>"""
            end
            label *= "</TABLE>>"
        end

        function shape(node)
            if !in(node, query) && !haskey(evidence, node) && !haskey(results, node)
                return "ellipse"
            else
                return "plaintext"
            end
        end

        plot(data, output_type; shape = shape, label = label, kwargs...)
    end
    export plot_prediction

    function plot_legend(output_type = graphviz.default_output_type, kwargs...)
        plot_prediction( (
                    nodes = [ :unknown, :output, :absent, :present, :result ],
                    edges = Dict{Pair{Symbol, Symbol}, Int}(),
                    descriptions = Dict{Symbol, String}()),
                Set{Symbol}([:output]), Dict{Symbol, Bool}(:present => true, :absent => false),
                Dict{Symbol, Float64}( :result => 0.3 ), output_type; shorten = false)
    end
    export plot_legend

    function validate(data, iterations::Int64, subsample_size::Int64, inference_method::String, args...; kwargs...)
        return validate(data, iterations, subsample_size, inference_methods[inference_method], args...; kwargs...)
    end
    export validate

    function validate(data, iterations::Int64, subsample_size::Int64, inference_method::Type,
                query::Set{Symbol}, model::Symbol , baseline_model::Symbol;
                pool = nothing, progress_array = nothing)
        try
            if progress_array != nothing
                progress_array_shape = size(progress_array)
                @assert progress_array_shape == (iterations, subsample_size)
            else
                progress_array = Array{Int64, 2}(undef, iterations, subsample_size)
            end

            function __remotecall(name, fun, args...)
                if pool != nothing
                    submission_attempts = 3
                    while true
                        try
                            task = Distributed.remotecall(fun, pool, args...)
                            println("Task submitted: " * name)
                            return task
                        catch(e)
                            submission_attempts -= 1
                            if submission_attempts > 0
                                println("Task submission failed, retrying: " * name)
                                println(e)
                                continue
                            else
                                println("Task submission failed, aborting after three attempts: " * name)
                                println(e)
                                rethrow(e)
                            end
                        end
                    end
                else
                    return @async fun(args...)
                end
            end

            evidence_variables = setdiff(Set{Symbol}(names(data.data)), query)
            model_tasks = []

            ready = SharedArrays.SharedArray{Int64}( (iterations, ), pids = (pool == nothing ? Int[] : collect(pool.workers) ))
            for iteration in 1:iterations
                samples = Random.randperm(size(data.data, 1))

                validation_samples = samples[1:subsample_size]
                training_samples   = samples[subsample_size + 1:end]

                @assert length(validation_samples) == subsample_size
                @assert length(validation_samples) + length(training_samples) == nrow(data.data)
                @assert length(intersect(validation_samples, training_samples)) == 0

                @assert min(validation_samples...) > 0
                @assert min(training_samples...)   > 0
                @assert max(validation_samples...) <= nrow(data.data)
                @assert max(training_samples...)   <= nrow(data.data)

                push!(model_tasks, (__remotecall(
                    "Training " * string(iteration), __validation_train, data,
                    model, baseline_model, training_samples, iteration, ready), validation_samples, ready))
            end


            println("Started " * string(iterations) * " model trainings")
            tasks = Dict()
            # only ever run the inference task when the model has been trained. Otherwise some workers will starve
            while length(tasks) < length(model_tasks)
                for (iteration, (training_result, validation_samples, ready)) in enumerate(model_tasks)
                    if ready[iteration] > 0 && !haskey(tasks, iteration)
                        println("Received training " * string(iteration))
                        tasks[iteration] = []
                        mod, blmod = fetch(training_result)

                        for (sample_number, sample_index) in enumerate(validation_samples)
                            st = __remotecall(
                                "Sample " * string(iteration) * "." * string(sample_number),
                                __validate_model, fetch(mod), fetch(blmod), iteration, sample_number, sample_index,
                                data.data, data.absent_is_unknown, query, evidence_variables, inference_method,  progress_array)
                            push!(tasks[iteration], st)
                        end
                        println("Started " * string(length(tasks) * subsample_size) * " predictions")
                    end
                end
                sleep(1)
            end

            # make sure we return data in the right order
            iteration_tasks = [ tasks[i] for i in 1:iterations ]
            return [ fetch(t) for t in vcat(iteration_tasks...)  ]
        catch e
            for (exc, bt) in Base.catch_stack()
                   showerror(stdout, exc, bt)
                   println()
            end
            rethrow(e)
        end
    end

    function __validation_train(data, model, baseline_model, subsample, iteration, ready)
        try
            println("Started training " * string(iteration))
            mod = train(data, Val(model), subsample)
            blmod = train(data, Val(baseline_model), subsample)
            ready[iteration] = 1
            println("Finished training " * string(iteration))
            return (mod, blmod)
        catch e
            for (exc, bt) in Base.catch_stack()
                   showerror(stdout, exc, bt)
                   println()
            end
            rethrow(e)
        end
    end

    function __validate_model(mod, blmod, iteration, sample_number, sample_index, data, absent_is_unknown, query, evidence_variables, inference_method, progress_array)
        try
            println("Sample " * string(iteration) * "." * string(sample_number))

            evidence = Dict{Symbol, Bool}()
            for ev in evidence_variables
                if !(ev in absent_is_unknown) || data[sample_index, ev] > 0
                    evidence[ev] = data[sample_index, ev]
                end
            end

            expected = Dict{Symbol, Bool}()
            for qv in query
                expected[qv] = data[sample_index, qv]
            end

            prediction = predict(mod, inference_method, query, evidence)
            baseline_prediction = predict(blmod, inference_method, query, evidence)

            progress_array[iteration, sample_number] += 1
            return [ (expected, prediction, baseline_prediction) ]
        catch e
            for (exc, bt) in Base.catch_stack()
                   showerror(stdout, exc, bt)
                   println()
            end
            rethrow(e)
        end
    end

    function calc_metrics(data = nothing)
        return Dict{String, Any}(n => f(data) for (n, f) in metrics)
    end
    export calc_metrics
end
