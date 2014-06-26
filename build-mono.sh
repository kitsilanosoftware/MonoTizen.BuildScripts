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

# This is a basic build configuration for mono, which allows
# specifying per-OS and per-arch options.

set -e

MONO_TIZEN_HOME="$HOME/mono-tizen"
BASE="$(dirname "$0")"
DO_RUN=

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

# Lookup OS in /etc/os-release, if available.

function fetch_os_id {
    source '/etc/os-release'
    echo "$ID"
}

if test -r '/etc/os-release'; then
    # Source in a subshell to avoid contamination.
    os_id="$(fetch_os_id)"
fi

# Normalize arch

arch="$(uname -m)"
case "$arch" in
    i686*)
        # Get rid of _emulated from emulator images.  Also: other
        # Intel archs?
        arch='i686'
        ;;
esac

# Reset.

unset CC CXX CFLAGS CXXFLAGS DISTCC_HOSTS
unset MONO_CONF_ARGS MONO_MAKE_ARGS

export MONO_TIZEN_SOURCES="$mono_sources"
export MONO_TIZEN_OS_ID="$os_id"
export MONO_TIZEN_ARCH="$arch"

# Source various environment files

source "$BASE/all.env"

if test -r "$BASE/distcc.env"; then
    source "$BASE/distcc.env"
fi

if test -r "$BASE/os-$MONO_TIZEN_OS_ID.env"; then
    source "$BASE/os-$MONO_TIZEN_OS_ID.env"
fi

if test -r "$BASE/arch-$MONO_TIZEN_ARCH.env"; then
    source "$BASE/arch-$MONO_TIZEN_ARCH.env"
fi

if test -r "$BASE/$MONO_TIZEN_OS_ID-$MONO_TIZEN_ARCH.env"; then
    source "$BASE/$MONO_TIZEN_OS_ID-$MONO_TIZEN_ARCH.env"
fi

# Complete distcc setup, if applicable

if test -n "$MONO_DISTCC_CC" -a -n "$MONO_DISTCC_CXX"   \
    -a -n "$MONO_DISTCC_BIN"; then
    CC="$MONO_DISTCC_BIN $MONO_DISTCC_CC"
    CXX="$MONO_DISTCC_BIN $MONO_DISTCC_CC"
    export DISTCC_HOSTS CC CXX
fi

# Building procedure

cd "$MONO_TIZEN_SOURCES"

if test "$1" = '--autogen'; then
    shift
    $DO_RUN ./autogen.sh $MONO_CONF_ARGS
elif test "$1" = '--configure'; then
    shift
    $DO_RUN ./configure $MONO_CONF_ARGS
fi

if test "$1" = '--build'; then
    shift
    $DO_RUN make $MONO_MAKE_ARGS
fi

if test "$1" = '--install'; then
    shift
    $DO_RUN make install
fi

if test -n "$*"; then
    echo "Unknown args $*." >&2
    false
fi
