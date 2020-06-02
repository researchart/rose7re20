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

module graphviz

    module GraphProps
        @enum EnumDef begin
            label
            rankdir
            ranksep
        end
    end

    module NodeProps
        @enum EnumDef begin
            fillcolor
            label
            margin
            shape
            style
            tooltip
        end
    end

    module EdgeProps
        @enum EnumDef begin
            color
            penwidth
            tooltip
        end
    end

    module OutputType
        @enum EnumDef begin
            dot
            xdg_open
            display
        end
    end

    default_output_type = (isdefined(Main, :IJulia) && Main.IJulia.inited) ? OutputType.display : OutputType.xdg_open

    struct Dot
        edges::Array{Pair{Symbol, Symbol}}
        nodes::Array{Symbol}

        graph_props::Dict{GraphProps.EnumDef, String}
        node_props::Dict{Symbol, Dict{NodeProps.EnumDef, String}}
        edge_props::Dict{Pair{Symbol, Symbol}, Dict{EdgeProps.EnumDef, String}}

        function Dot(nodes, edges)
            nodes = collect(nodes)
            for edge in edges
                push!(nodes, edge.first)
                push!(nodes, edge.second)
            end

            new(collect(edges), unique(nodes),
                Dict{GraphProps.EnumDef, String}(),
                Dict{Symbol, Dict{NodeProps.EnumDef, String}}(),
                Dict{Pair{Symbol, Symbol}, Dict{EdgeProps.EnumDef, String}}())
        end
    end
    export Dot

    function set(graph::Dot, node::Symbol, prop::NodeProps.EnumDef, value)
        get!(graph.node_props, node, Dict{NodeProps.EnumDef, String}())[prop] = string(value)
    end

    function set(graph::Dot, edge::Pair{Symbol, Symbol}, prop::EdgeProps.EnumDef, value)
        get!(graph.edge_props, edge, Dict{EdgeProps.EnumDef, String}())[prop] = string(value)
    end

    function set(graph::Dot, prop::GraphProps.EnumDef, value)
        graph.graph_props[prop] = string(value)
    end
    export set

    function plot(graph::Dot, output_type::OutputType.EnumDef = default_output_type)
        plot(graph, Val(output_type))
    end

    function plot(graph::Dot, output_type::String)
        dotsrc = plot(graph, Val(OutputType.dot))

        dotfile = tempname()
        outfile = tempname()
        try
            write(dotfile, dotsrc)
            run(`dot -o$outfile -T$output_type $dotfile`)
            return read(outfile)
        finally
            rm(dotfile, force = true)
            rm(outfile, force = true)
        end
    end

    function plot(graph::Dot, output_type::Val{OutputType.dot})
        dotsrc = "digraph \"\" {\n"
        dotsrc *= "graph" * __to_dot_props(graph.graph_props)

        for node in graph.nodes
            dotsrc *= __to_dot_string(node) * __to_dot_props(get(graph.node_props, node, Dict{NodeProps.EnumDef, String}()))
        end

        for edge in graph.edges
            dotsrc *= __to_dot_string(edge.first) * " -> " * __to_dot_string(edge.second) * __to_dot_props(get(graph.edge_props, edge, Dict{EdgeProps.EnumDef, String}()))
        end

        dotsrc *= "}"
        return dotsrc
    end

    function plot(graph::Dot, output_type::Val{OutputType.display})
        pngdata = plot(graph, "png")
        Base.display("image/png", pngdata)
    end

    function plot(graph::Dot, output_type::Val{OutputType.xdg_open})
        pngdata = plot(graph, "svg")

        pngfile = tempname()
        write(pngfile, pngdata)
        atexit(() -> rm(pngfile, force = true))
        run(`xdg-open $pngfile`)
    end

    export plot

    function __to_dot_string(obj::Any)
        return replace(string(obj), ("\"" => "\\\""))
    end

    function __to_dot_props(props::Union{Dict{GraphProps.EnumDef, String}, Dict{NodeProps.EnumDef, String}, Dict{EdgeProps.EnumDef, String}})
        out = [ ]
        for (key, value) in props
            key = string(key)

            if value[1] == '<' && value[end] == '>'
                # HTML strings: pass as they are, without escaping
                # since we cannot do that for the caller
            else
                # Normal strings: escape for the caller
                value = __to_dot_string(value)
                value = "\"$value\""
            end

            push!(out, "$key = $value")
        end

        return " [" * join(out, ", ") * "];\n"
    end

end
