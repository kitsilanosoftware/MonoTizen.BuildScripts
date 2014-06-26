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

export LANG=C

# Figure out Mono sources location.

if test "$1" = '--sources'; then
    mono_sources="$2"
    shift 2
else
    mono_sources="$MONO_TIZEN_HOME/mono-sources"
fi

if ! test -r "$mono_sources/mono-core.spec.in"; then
    echo "Mono sources not found in $mono_sources; use --sources." >&2
    exit 1
fi

# Testing procedure

cd "$mono_sources"

if test "$1" = '--log-base' -a -n "$2"; then
    log_base="$2"
    shift 2
fi

if test -z "$log_base" -o ! -d "$log_base"; then
    echo "No log base set, use --log-base <dir> as first arg." >&2
    false
fi

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
    local fixture make_args status

    if test -n "$1"; then
        fixture="$1"; shift
        make_args="TEST_HARNESS_FLAGS=-fixture=$fixture"
    fi

    mkdir -p "$log_base/mcs/class/$lib"

    (
        cd "mcs/class/$lib" &&
        make run-test $make_args
    ) 2>&1 | tee "$log_base/mcs/class/$lib/$HOSTNAME.log"

    status=${PIPESTATUS[0]}
    if test $status -ne 0; then
        return $status
    fi
}

if test "$1" = '--mono-mini'; then
    test_subdir_unique_target 'mono/mini' 'rcheck'
    shift
fi

if test "$1" = '--mono-tests'; then
    test_subdir_unique_target 'mono/tests' 'check-local'
    shift
fi

if test "$1" = '--mono-tests-gc-descriptors'; then
    test_subdir_unique_target 'mono/tests/gc-descriptors' 'check-local'
    shift
fi

if test "$1" = '--mcs-class-lib' -a -n "$2"; then
    test_mcs_class_lib "$2"
    shift 2
fi

if test "$1" = '--mcs-class-lib-fixture' -a -n "$2" -a -n "$3"; then
    test_mcs_class_lib "$2" "$3"
    shift 3
fi

if test -n "$*"; then
    echo "Unknown args $*." >&2
    false
fi
