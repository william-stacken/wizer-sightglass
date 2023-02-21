#!/usr/bin/env bash

# Run all of the benchmarks found in the `benchmarks` directory.
#
# Usage: ./run-all.sh

set -e
PROJECT_DIR=$(cd "$(dirname "$0")" && pwd -P | xargs dirname)
RESULT_DIR=$PROJECT_DIR/benchmarks/_results/$(date +"%F_%H%M%S")
SIGHTGLASS="cargo +nightly run --bin sightglass-cli --"
ENGINE=$PROJECT_DIR/engines/wasmtime/libengine.so
SIGHTGLASS_OPTIONS="--engine $ENGINE --processes 1 --iterations-per-process 3 --raw --output-format csv"
export RUST_LOG=debug

# If an engine is not available, build it.
if [[ ! -f $ENGINE ]]; then
    pushd $PROJECT_DIR/engines/wasmtime
    rustc build.rs
    ./build
    popd
fi

if [[ -d $RESULT_DIR ]]; then
    echo "Suspected previous results detected at $RESULT_DIR. Please back-up or delete the folder and try again."
    exit 1
else
    mkdir -p $RESULT_DIR
fi

# Benchmark each Wasm file.
for BENCH_FILE in $(find $PROJECT_DIR/benchmarks -name benchmark.wasm); do
    # Find corresponding wizened Wasm module
    BENCH_DIR=$(dirname $BENCH_FILE)
    BENCH_FILE_WIZER=$BENCH_DIR/wizer.benchmark.wasm

    RESULT_NAME=$(basename $BENCH_DIR).csv
    RESULT_NAME_WIZER=wizer.$RESULT_NAME

    $SIGHTGLASS benchmark $SIGHTGLASS_OPTIONS -o $RESULT_DIR/$RESULT_NAME --working-dir $BENCH_DIR $BENCH_FILE
    if [[ -f $BENCH_FILE_WIZER ]]; then
        $SIGHTGLASS benchmark $SIGHTGLASS_OPTIONS -o $RESULT_DIR/$RESULT_NAME_WIZER --working-dir $BENCH_DIR $BENCH_FILE_WIZER
    fi
done
