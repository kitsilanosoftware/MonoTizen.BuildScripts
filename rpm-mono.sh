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

BASE="$(dirname "$0")"
MONO_TIZEN_PREFIX='/opt/crosstwine/mono-tizen'
MONO_RPM_WORK="$MONO_TIZEN_PREFIX/build/rpm"

# Source host-based environment files

source "$BASE/rpm.env"

MONO_RPM_TARBALL="$MONO_RPM_WORK/SOURCES/mono-$MONO_RPM_VERSION.tar.bz2"
MONO_RPM_SPEC_BASENAME="mono-core-$MONO_RPM_VERSION-1.spec"
MONO_RPM_SPEC="$MONO_RPM_WORK/SPECS/$MONO_RPM_SPEC_BASENAME"

# Building procedure

if test "$1" = '--macros'; then
    shift
    rm -f "$HOME/.rpmmacros"
    cp "$BASE/rpm/macros" "$HOME/.rpmmacros"
fi

cd "$MONO_TIZEN_PREFIX/build/mono"

if test "$1" = '--dist'; then
    shift
    make dist-bzip2
    mv "mono-$MONO_RPM_VERSION.tar.bz2" "$MONO_RPM_WORK/SOURCES"
    mv mono-core.spec "$MONO_RPM_SPEC"
fi

cd "$MONO_TIZEN_PREFIX/build/rpm/SPECS"

if test "$1" = '--prepare'; then
    shift
    rpmbuild -bp $MONO_RPMBUILD_ARGS "$MONO_RPM_SPEC_BASENAME"
fi

if test "$1" = '--build'; then
    shift
    rpmbuild -bc $MONO_RPMBUILD_ARGS "$MONO_RPM_SPEC_BASENAME"
fi

if test "$1" = '--binary'; then
    shift
    rpmbuild -bb $MONO_RPMBUILD_ARGS "$MONO_RPM_SPEC_BASENAME"
fi
