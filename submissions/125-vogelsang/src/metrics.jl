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

module Metrics
    function __foreach(data, count_fun_configs, count_fun_numerator, count_fun_denominator = (e, p, c) -> length(e))
        values = []

        value_total             = 0.0
        baseline_total          = 0.0
        value_config_counter    = 0
        baseline_config_counter = 0


        for config in count_fun_configs
            total = 0
            value_counter = 0.0
            baseline_counter = 0.0
            for iteration_data in data
                for (expected, predicted, baseline_predicted) in iteration_data
                    total += count_fun_denominator(expected, predicted, config)

                    value_counter      += count_fun_numerator(expected, predicted, config)
                    baseline_counter   += count_fun_numerator(expected, baseline_predicted, config)
                end
            end

            value = value_counter / total
            baseline = baseline_counter / total
            push!(values, (config = config, value = value, baseline = baseline))

            value_total    += !ismissing(value) && isfinite(value)    ? value : 0
            baseline_total += !ismissing(value) && isfinite(baseline) ? baseline : 0
            value_config_counter    += 1
            baseline_config_counter += 1
        end

        return [(   config = config, value = value, baseline = baseline,
                    value_average    = value_total    / value_config_counter,
                    baseline_average = baseline_total / baseline_config_counter)
                        for (config, value, baseline) in values ]
    end

    function brier_score(data)
        bs = __foreach(data, [ nothing ], ( e, p, c ) -> sum([ (convert(Int, e[s]) - p[s])^2 for s in keys(e) ]))
        return (limits = [ 0, 1 ], data = bs)
    end

    function ranking(data, config = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
        data = __foreach(data, config,
            function(expected, predicted, c)
                if c > length(predicted); return missing; end

                predicted_highest = sort(collect(predicted), by = ex -> -ex[2])
                return sum(expected[k] for (k, _) in predicted_highest[1:c])
            end,
            (expected, p, t) -> sum(ex[2] for ex in expected))

        return (limits = [ 0, 1 ], data_xlabel = "Ranking length", data = data)
    end

    function ranking_precision(data, config = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
        data = __foreach(data, config,
            function(expected, predicted, c)
                if c > length(predicted); return missing; end

                predicted_highest = sort(collect(predicted), by = ex -> -ex[2])
                return sum(expected[k] for (k, _) in predicted_highest[1:c])
            end,
            (expected, p, t) -> t)

        return (limits = [ 0, 1 ], data_xlabel = "Ranking length", data = data)
    end

    function binary_accuracy(data, config = [ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 ])
        data = __foreach(data, config, (e, p, t) -> length([ s for s in keys(e) if e[s] == (p[s] > t) ]) )
        return (limits = [ 0, 1 ], data_xlabel = "Probability threshold", data = data)
    end

    function recall(data, config = [ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 ])
        data = __foreach(data, config,
                (e, p, t) -> sum([ p[s] > t ? 1 : 0 for s in keys(e) if e[s] ]),
                (e, p, t) -> sum([ convert(Int, v) for v in values(e) ]))
        return (limits = [ 0, 1 ], data_xlabel = "Probability threshold", data = data)
    end

    function precision(data, config = [ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 ])
        data = __foreach(data, config,
                (e, p, t) -> sum( [ convert(Int, e[s]) for s in keys(p) if p[s] > t ] ),
                (e, p, t) -> sum([ 1 for s in keys(p) if p[s] > t ]))
        return (limits = [ 0, 1 ], data_xlabel = "Probability threshold",
                    data = data)
    end
end
