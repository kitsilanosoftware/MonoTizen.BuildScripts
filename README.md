# MonoTizen Build Scripts

Shared build scripts for Mono in Tizen environments

## Licenses

Currently "all rights reserved"; the licensing terms (MIT?) are to be
decided by Bob Summerwill and Damien Diederen <dd@crosstwine.com>.

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
