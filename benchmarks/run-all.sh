#!/usr/bin/env bash

# Run all of the benchmarks found in the `benchmarks` directory.
#
# Usage: ./run-all.sh

set -e
PROJECT_DIR=$(cd "$(dirname "$0")" && pwd -P | xargs dirname)
if [[ "$PROJECT_DIR" != "$(dirname $PWD)" ]]; then
	echo "This script can only be run from its parent directory at $PROJECT_DIR/benchmarks"
fi
PROJECT_DIR=..
RESULT_TIME=$(date +"%F_%H%M%S")
RESULT_ROOT_DIR=_results
RESULT_DIR=$RESULT_ROOT_DIR/$RESULT_TIME
SIGHTGLASS="cargo +nightly run --bin sightglass-cli --"
ENGINE=./wasmtime
SIGHTGLASS_OPTIONS="--engine $ENGINE -m perf-counters --raw --output-format csv"
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
for BENCH_FILE in $(find . -name benchmark.wasm); do
    # Find corresponding wizened Wasm module
    BENCH_DIR=$(dirname $BENCH_FILE)
    BENCH_FILE_WIZER=$BENCH_DIR/wizer.benchmark.wasm

    RESULT_NAME=$(basename $BENCH_DIR).csv
    RESULT_NAME_RAW=$(basename $BENCH_DIR).raw.csv

    TMP_RESULT=$(mktemp /tmp/sightglass-benchmark-XXXXXX.csv)
    $SIGHTGLASS benchmark $SIGHTGLASS_OPTIONS --working-dir $BENCH_DIR $BENCH_FILE 2>/dev/null | \
        sed -e 's/\.\///g' -e 's/\/benchmark.wasm//g' | \
        tee $RESULT_NAME_RAW | \
        $SIGHTGLASS summarize -i csv -o csv > $TMP_RESULT
    
    $SIGHTGLASS benchmark $SIGHTGLASS_OPTIONS --working-dir $BENCH_DIR $BENCH_FILE_WIZER 2>/dev/null | \
        sed -e 's/\.\///g' -e 's/\/wizer.benchmark.wasm//g' | \
        tee $RESULT_NAME_RAW | \
        $SIGHTGLASS summarize -i csv -o csv | \
        python3 -c "import sys, csv
joined = csv.writer(sys.stdout)
with open(\"$TMP_RESULT\") as baseline:
    for wizerrow, row in zip(csv.reader(sys.stdin), csv.reader(baseline)):
        if wizerrow[:5] != row[:5]:
            raise Exception('Unexpected row order for ' + str(row) + ' and ' + str(wizerrow))

        joined.writerow(row + wizerrow[5:])" > $RESULT_DIR/$RESULT_NAME
done

ALL_RESULTS=$(cat $RESULT_DIR/*.csv)
echo "$ALL_RESULTS" | grep Compilation > $RESULT_DIR/__compilation.csv
echo "$ALL_RESULTS"| grep Instantiation > $RESULT_DIR/__instantiation.csv
echo "$ALL_RESULTS" | grep Execution > $RESULT_DIR/__execution.csv

# Update symlink pointing to latest result
rm -f $RESULT_ROOT_DIR/latest
ln -s $RESULT_TIME $RESULT_ROOT_DIR/latest
