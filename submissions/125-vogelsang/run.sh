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

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=hsnrp:
LONGOPTS=help,shell,nodep,revise,procs:

# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

shell=n nodep=n revise=n
procs=$(grep -c \^processor /proc/cpuinfo)

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -s|--shell)
            shell=y
            shift
            ;;
        -n|--nodep)
            nodep=y
            shift
            ;;
        -r|--revise)
            revise=y
            shift
            ;;
        -p|--procs)
            procs="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--shell|--nodep|--revise|--help]"
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# -ne 0 ]]; then
    echo "$0: No positional arguments are supported. Try --help."
    exit 4
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export JULIA_PROJECT="$DIR"
export JULIA_REVISE_INCLUDE="1"

loadcode="revise_enabled = false"
if [ $revise == "y" ]; then
    echo "Enabling revise"
    loadcode="
revise_enabled = true
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
"
fi
loadcode="$loadcode
import napire
"

tmp=$(mktemp)
trap "{ rm -f '$tmp'; }" EXIT

if [ $shell = "n" ]; then
    if [ $nodep = "n" ]; then
        deps="import Pkg; Pkg.instantiate();"
        ( cd "$DIR/userweb" && npm install && npm run build-prod || echo "Failed compiling angular app" )
    fi
    echo "$deps $loadcode; import napire; napire.web.start(Dict(\"/web/\" => \"$DIR/web\", \"/userweb/\" => \"$DIR/userweb/build-prod\"), joinpath(\"$DIR\", \"results\"); maximum_tasks = $procs, revise = revise_enabled);" > "$tmp"

    julia "$tmp"
else
    echo "atreplinit() do repl
    @eval begin
        $loadcode
    end
end"> "$tmp"

    julia -L "$tmp"
fi
