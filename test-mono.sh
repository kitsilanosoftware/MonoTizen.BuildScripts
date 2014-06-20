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

MONO_TIZEN_PREFIX='/opt/crosstwine/mono-tizen'
MONO_TEST_LOG_BASE=

export LANG=C

# Host-based initialization, currently a no-op.

case "$HOSTNAME" in
    mini|tizn|teiz|thoz|thaz)
        ;;
    *)
        echo "Unknown host $HOSTNAME." >&2
        false
        ;;
esac

# Building procedure

cd "$MONO_TIZEN_PREFIX/build/mono"

if test "$1" = '--log-base' -a -n "$2"; then
    MONO_TEST_LOG_BASE="$2"
    shift 2
fi

if test -z "$MONO_TEST_LOG_BASE"; then
    echo "No log base set, use --log-base <dir> as first arg." >&2
    false
fi

function test_mcs_class_lib {
    local lib="$1"; shift
    local fixture make_args status

    if test -n "$1"; then
        fixture="$1"; shift
        make_args="TEST_HARNESS_FLAGS=-fixture=$fixture"
    fi

    mkdir -p "$MONO_TEST_LOG_BASE/mcs/class/$lib"

    (
        cd "mcs/class/$lib" &&
        make run-test $make_args
    ) 2>&1 | tee "$MONO_TEST_LOG_BASE/mcs/class/$lib/$HOSTNAME.log"
    status=${PIPESTATUS[0]}

    if test $status -ne 0; then
        return $status
    fi
}

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
