#!/usr/bin/env bash

# Build a single benchmark using the `Dockerfile` in its benchmark directory. Expects the benchmark
# directory to contain a `Dockerfile` that emits a `benchmark.wasm` file that meets the Sightglass
# requirements (see `README.md`).
#
# Usage: ./build.sh <path to benchmark directory> <optional filename>

set -e

BENCHMARK_DIR=$1
if [[ ! -d $BENCHMARK_DIR ]]; then
    echo "Unknown benchmark directory; usage: ./build.sh <path to benchmark directory>"
    exit 1
fi

# If the filename is provided, use it.
FILENAME=$2
if [[ -z $FILENAME ]]; then
    # Otherwise assume the filename is "benchmark.wasm"
    FILENAME=benchmark.wasm
fi

BENCHMARK_NAME=$(readlink -f $BENCHMARK_DIR | xargs basename)
IMAGE_NAME=sightglass-benchmark-$BENCHMARK_NAME
IMAGE_NAME_WIZER=$IMAGE_NAME-wizer
TMP_BENCHMARK=$(mktemp /tmp/sightglass-benchmark-XXXXXX.wasm)
TMP_BENCHMARK_WIZER=$(mktemp /tmp/sightglass-benchmark-XXXXXX.wizer.wasm)
>&2 echo "Building $BENCHMARK_DIR"

# Helpful logging function.
print_header() {
    >&2 echo
    >&2 echo ===== $@ =====
}

# To allow the use of symlinks in the benchmark directories (docker ignores them), we `tar` up the
# directory and `--dereference` (i.e., follow) all symlinks provided.
print_header "Create build context"
TMP_TAR=$(mktemp /tmp/sightglass-benchmark-dir-XXXXXX.tar)
(set -x; cd $BENCHMARK_DIR && tar --create --file $TMP_TAR --dereference --verbose .)

# Build the benchmark image and extract the generated `benchmark.wasm` file from its container.
print_header "Build benchmark"
(set -x; docker build --tag $IMAGE_NAME - < $TMP_TAR)
CONTAINER_ID=$(set -x; docker create $IMAGE_NAME)
(set -x; docker cp $CONTAINER_ID:/$FILENAME $TMP_BENCHMARK)

# Verify benchmark is a valid Sightglass benchmark.
print_header "Verify benchmark"
# From https://stackoverflow.com/a/246128:
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
SIGHTGLASS_CARGO_TOML=$(dirname $SCRIPT_DIR)/Cargo.toml
(set -x; cargo run --manifest-path $SIGHTGLASS_CARGO_TOML --quiet -- validate $TMP_BENCHMARK)
(set -x; mv $TMP_BENCHMARK $BENCHMARK_DIR/$FILENAME)
# `tar` up the directory and `--dereference` (i.e., follow) all symlinks provided again now that
# the baseline wasm has been built.
(set -x; cd $BENCHMARK_DIR && tar --create --file $TMP_TAR --dereference --verbose .)

print_header "Build wizened benchmark"
(set -x; docker build -f Dockerfile.wizer --tag $IMAGE_NAME_WIZER - < $TMP_TAR)
CONTAINER_ID_WIZER=$(set -x; docker create $IMAGE_NAME_WIZER)
(set -x; docker cp $CONTAINER_ID_WIZER:/wizer.$FILENAME $TMP_BENCHMARK_WIZER)

# Verify wizened benchmark is a valid Sightglass benchmark.
print_header "Verify wizened benchmark"
(set -x; cargo run --manifest-path $SIGHTGLASS_CARGO_TOML --quiet -- validate $TMP_BENCHMARK_WIZER)
(set -x; mv $TMP_BENCHMARK_WIZER $BENCHMARK_DIR/wizer.$FILENAME)

# Clean up.
print_header "Clean up"
(set -x; rm $TMP_TAR)
(set -x; docker rm $CONTAINER_ID)
# We do not remove the image and intermediate images here (e.g., `docker rmi $IMAGE_NAME`) to speed
# up `build-all.sh`; use `clean.sh` instead.
