#!/bin/bash

# Copyright 2014 Kitsilano Software Inc.
#
# This file is part of MonoTizen.
#
# MonoTizen is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MonoTizen is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with MonoTizen.  If not, see <http://www.gnu.org/licenses/>.

set -e

MONO_TIZEN_HOME="$HOME/mono-tizen"

log_base=
mono_sources="$MONO_TIZEN_HOME/mono-sources"
profile_arg=
profile_log_subdir=

export LANG=C

# Testing procedure

function ensure_ready {
    if ! test -r "$mono_sources/mono-core.spec.in"; then
        echo "Mono sources not found in $mono_sources; use --sources." >&2
        exit 1
    fi

    if test -z "$log_base" -o ! -d "$log_base"; then
        echo "No log base set, use --log-base <dir> as first arg." >&2
        exit 1
    fi

    cd "$mono_sources"
    mono_sources='.'
}

function test_subdir_unique_target {
    local subdir="$1"; shift
    local target="$1"; shift
    local log_dir="$log_base/$subdir"

    mkdir -p "$log_dir"

    (
        cd "$subdir" &&
        make "$target"
    ) 2>&1 | tee "$log_dir/$HOSTNAME.log"

    status=${PIPESTATUS[0]}
    if test $status -ne 0; then
        return $status
    fi
}

function test_mcs_class_lib {
    local lib="$1"; shift
    local make_args="$profile_arg"
    local log_dir="$log_base/mcs/class/$profile_log_subdir$lib"
    local fixture status

    if test -n "$1"; then
        fixture="$1"; shift
        make_args="$make_args TEST_HARNESS_FLAGS=-fixture=$fixture"
    fi

    mkdir -p "$log_dir"

    (
        cd "mcs/class/$lib" &&
        make run-test $make_args
    ) 2>&1 | tee "$log_dir/$HOSTNAME.log"

    status=${PIPESTATUS[0]}
    if test $status -ne 0; then
        return $status
    fi
}

while test -n "$*"; do
    case "$1" in
        --log-base)
            log_base="$2"
            shift 2
            ;;
        --sources)
            mono_sources="$2"
            shift 2
            ;;
        --mono-mini)
            ensure_ready
            test_subdir_unique_target 'mono/mini' 'rcheck'
            shift
            ;;
        --mono-tests)
            ensure_ready
            test_subdir_unique_target 'mono/tests' 'check-local'
            shift
            ;;
        --mono-tests-gc-descriptors)
            ensure_ready
            test_subdir_unique_target 'mono/tests/gc-descriptors' 'check-local'
            shift
            ;;
        --profile)
            test -n "$2"
            profile_arg="PROFILE=$2"
            profile_log_subdir="$2/"
            shift 2
            ;;
        --mcs-class-lib)
            test -n "$2"
            ensure_ready
            test_mcs_class_lib "$2"
            shift 2
            ;;
        --mcs-class-lib-fixture)
            test -n "$2"
            test -n "$3"
            ensure_ready
            test_mcs_class_lib "$2" "$3"
            shift 3
            ;;
        *)
            echo "Unknown args $*." >&2
            exit 1
            ;;
    esac
done
