#!/bin/bash

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

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR="`dirname $DIR`" # remove src
export JULIA_PROJECT="$DIR"
export JULIA_REVISE_INCLUDE="1"

tmp=$(mktemp)
function exit {
    rm -f '$tmp';
    for i in `ps --ppid $$ -o pid=`; do
        kill -9 $i 1>/dev/null 2>/dev/null
    done
}
trap exit EXIT

echo "
using Revise

files = [];
for (root, _, dirfiles) in walkdir(\"$DIR/src\")
    for file in dirfiles
        push!(files, joinpath(root, file));
    end
end

@async Revise.entr(files, [ ]) do
    println(\"-- reload --\")
end
using napire
import napire

import Distributed
Distributed.start_worker()
" > "$tmp"

julia --bind-to 127.0.0.1 "$tmp"
