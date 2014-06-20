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
BASE="$(dirname "$0")"
DO_RUN=

unset CC CXX CFLAGS CXXFLAGS DISTCC_HOSTS
unset MONO_CONF_ARGS MONO_MAKE_ARGS

# Source host-based environment files

source "$BASE/build.env"

if test -r "$BASE/distcc.env"; then
    # Symbolic link to e.g. crosstwine/distcc.env
    source "$BASE/distcc.env"
fi

case "$HOSTNAME" in
    mini)
        ;;
    tizn|teiz|thoz|thaz)
        source "$BASE/build-without-mcs.env"
        ;;
    *)
        echo "Unknown host $HOSTNAME." >&2
        false
        ;;
esac

source "$BASE/$HOSTNAME/build.env"

# Complete distcc setup, if applicable

if test -n "$MONO_DISTCC_CC" -a -n "$MONO_DISTCC_CXX"   \
    -a -n "$MONO_DISTCC_BIN"; then
    CC="$MONO_DISTCC_BIN $MONO_DISTCC_CC"
    CXX="$MONO_DISTCC_BIN $MONO_DISTCC_CC"
    export DISTCC_HOSTS CC CXX
fi

# Building procedure

cd "$MONO_TIZEN_PREFIX/build/mono"

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
