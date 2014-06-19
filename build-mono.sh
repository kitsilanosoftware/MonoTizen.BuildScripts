#!/bin/bash

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
