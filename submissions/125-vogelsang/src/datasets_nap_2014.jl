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

function nap_2014(args...)
    FILENAME = joinpath(dirname(@__FILE__), "../data/2014/napire.csv")
    CONTEXT_FILENAME = joinpath(dirname(@__FILE__), "../data/2014/napire-subjects.csv")

    #
    # CSV parsing
    #

    to_col_name = function(secname, number)
        return Symbol("$(String(secname))_$(@sprintf("%02d", number))")
    end

    data = CSV.read(FILENAME; datarow = 1, delim = ';', quotechar = '"')
    data_meta = data[1:4, :]
    data = data[4:end, :]

    current_title = ""
    current_subtitle = ""
    current_framestart = 0
    items = Dict{Symbol, Set{Symbol}}()
    descriptions = Dict{Symbol, Union{Missing, String}}()
    for i in 1:size(data_meta)[2]
        if !ismissing(data_meta[1, i])
            current_title = data_meta[1, i]
            current_subtitle = ""
            current_framestart = i
        end
        if !ismissing(data_meta[2, i])
            current_subtitle = data_meta[2, i]
            current_framestart = i
        end

        secname = "$(current_title)_$(current_subtitle)"

        colname = to_col_name(secname, i - current_framestart)
        rename!(data, names(data)[i] => colname)
        descriptions[colname] = data_meta[3, i]

        if current_subtitle == "CODE" || current_subtitle == "CATEGORIES"
            if current_framestart == i
                items[Symbol(secname)] = Set{Symbol}()
            end

            data[colname] = .! ismissing.(data[colname])
            push!(items[Symbol(secname)], colname)
        elseif current_subtitle == "FAILURE"
            data[colname] = data[colname] .== "1"
        end
    end

    contextdata = CSV.read(CONTEXT_FILENAME; datarow = 2, delim = ';', quotechar = '"')
    contextdata_columns = [
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_00, "Company size undetermined", x -> x == "0"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_01, "Company size 1-10", x -> x == "1-10"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_02, "Company size 11-50", x -> x == "11-50"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_03, "Company size 51-250", x -> x == "51-250"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_04, "Company size 251-500", x -> x == "251-500"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_05, "Company size 501-1000", x -> x == "501-1000"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_06, "Company size 1001-2000", x -> x == "1001-2000"),
        (:v_1,   :CONTEXT_SIZE, :CONTEXT_SIZE_07, "Company size 2000+", x -> x == "2000+"),

        (:V_10,  :CONTEXT_GLOBAL, :CONTEXT_GLOBAL_00, "Globally distributed projects", x -> x == "Yes"),
        (:v_557, :CONTEXT_DEV, :CONTEXT_DEV_CODE_00, "Waterfall", x -> x == "quoted"),
        (:v_558, :CONTEXT_DEV, :CONTEXT_DEV_CODE_01, "V-Model XT", x -> x == "quoted"),
        (:v_559, :CONTEXT_DEV, :CONTEXT_DEV_CODE_02, "Scrum", x -> x == "quoted"),
        (:v_560, :CONTEXT_DEV, :CONTEXT_DEV_CODE_03, "Extreme Programming",x -> x == "quoted"),
        (:v_561, :CONTEXT_DEV, :CONTEXT_DEV_CODE_04, "Rational Unified Process", x -> x == "quoted") ]

    rename!(data, Dict(:IDENTIFIERS_RANK_00 => :RANK, :IDENTIFIERS_SUBJECT_00 => :ID))
    rename!(contextdata, Dict(:SubjectUniqueID => :ID))

    data[:RANK] = parse.(UInt, data[:RANK])

    data = __join_contextdata!(data, items, descriptions, contextdata, contextdata_columns)
    return __filter(data, items, descriptions, args...)
end
