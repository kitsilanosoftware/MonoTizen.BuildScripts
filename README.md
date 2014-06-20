# MonoTizen Build Scripts

Shared build scripts for Mono in Tizen environments

## Licenses

MonoTizen is Copyright 2014 Kitsilano Software Inc.

MonoTizen is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MonoTizen is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MonoTizen.  If not, see <http://www.gnu.org/licenses/>.

## Usage

These scripts are very basic, and only encode the steps (and variance
between steps) required to compile Mono in various VM configurations.

### build-mono.sh

Captures the various per-VM options used to compile Mono.

    ./build-mono.sh [--autogen|--configure] [--build] [--install]

The correct configuration and build options that are passed down to
the Mono build scripts depend on the build host.  Have a look at the
script for details; questions to Damien Diederen <dd@crosstwine.com>.

### test-mono.sh

Captures the commands used to run various portions of the Mono test
suites, and keeping a consistent set of logs from VM to VM.

    ./build-mono.sh --log-base <dir> [--mcs-class-lib <lib>] [--mcs-class-lib-fixture <lib> <fixture>]

The `--log-base <dir>` argument is currently mandatory.  Test logs are
written to `<dir>/$TEST_DOMAIN/$HOSTNAME.log`, where `$TEST_DOMAIN`
denotes the library or subsystem being tested.
