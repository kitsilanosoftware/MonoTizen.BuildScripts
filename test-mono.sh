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
BASE="$(dirname "$0")"

log_base=
mono_sources="$MONO_TIZEN_HOME/mono-sources"
net_profile=

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
    ) 2>&1 | tee "$log_dir/$HOSTNAME.log.wip"

    status=${PIPESTATUS[0]}
    if test $status -ne 0; then
        return $status
    fi

    rm -f "$log_dir/$HOSTNAME.log"
    mv "$log_dir/$HOSTNAME.log.wip" "$log_dir/$HOSTNAME.log"
}

function test_mcs_run_tests {
    local mcs_subdir="$1"; shift
    local dir="$1"; shift
    local log_dir="$log_base/mcs/$mcs_subdir"
    local make_args fixture status

    if test -n "$net_profile"; then
        make_args="PROFILE=$net_profile"
        log_dir="$log_dir$net_profile/"
    fi

    log_dir="$log_dir$dir"

    if test -n "$1"; then
        fixture="$1"; shift
        make_args="$make_args TEST_HARNESS_FLAGS=-fixture=$fixture"
    fi

    mkdir -p "$log_dir"

    (
        cd "mcs/$mcs_subdir$dir" &&
        make run-test $make_args
    ) 2>&1 | tee "$log_dir/$HOSTNAME.log.wip"

    status=${PIPESTATUS[0]}
    if test $status -ne 0; then
        return $status
    fi

    rm -f "$log_dir/$HOSTNAME.log"
    mv "$log_dir/$HOSTNAME.log.wip" "$log_dir/$HOSTNAME.log"
}

function test_mcs_centum_tests {
    local abs_base="$(cd "$BASE" && pwd)"
    local ct_list="$(echo "${TMPDIR:-/tmp}/$UID-$$-centum-tests.list")"
    local make_args

    if test -n "$net_profile"; then
        make_args="PROFILE=$net_profile"
    fi

    ensure_ready
    rm -f "$ct_list"
    make -C 'mcs' -f "$abs_base/extract-centum-tests.mk"        \
        $make_args "$ct_list"

    for ct in $(cat $ct_list); do
        case "$ct" in
            class/*)
                test_mcs_run_tests 'class/' "${ct#class/}"
                ;;
            tests|errors)
                test_mcs_run_tests '' "$ct"
                ;;
            *)
                echo "Unexpected centum test name $ct." >&2
                exit 1
                ;;
        esac
    done
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
            net_profile="$2"
            shift 2
            ;;
        --mcs-all-centum)
            test_mcs_centum_tests
            shift 1
            ;;
        --mcs-tests)
            ensure_ready
            test_mcs_run_tests '' 'tests'
            shift 2
            ;;
        --mcs-errors)
            ensure_ready
            test_mcs_run_tests '' 'errors'
            shift 2
            ;;
        --mcs-class-lib)
            test -n "$2"
            ensure_ready
            test_mcs_run_tests 'class/' "$2"
            shift 2
            ;;
        --mcs-class-lib-fixture)
            test -n "$2"
            test -n "$3"
            ensure_ready
            test_mcs_run_tests 'class/' "$2" "$3"
            shift 3
            ;;
        *)
            echo "Unknown args $*." >&2
            exit 1
            ;;
    esac
done
