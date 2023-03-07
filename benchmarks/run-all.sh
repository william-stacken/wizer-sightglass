#!/usr/bin/env bash

# Run all of the benchmarks found in the `benchmarks` directory.
#
# Usage: ./run-all.sh

set -e
PROJECT_DIR=$(cd "$(dirname "$0")" && pwd -P | xargs dirname)
if [[ "$PROJECT_DIR" != "$(dirname $PWD)" ]]; then
	echo "This script can only be run from its parent directory at $PROJECT_DIR/benchmarks"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    I_AM_MACOS=1
fi

# Sort by the baseline CSV from stdin by the mean in ascending order
PYTHON_CSV_SORTER="import sys, csv
csv.writer(sys.stdout).writerows(sorted(csv.reader(sys.stdin), key=lambda row: row[8], reverse=False))
"
# Join the baseline CSV given as argument with the optimized CSV from stdin
# row-wise from the fifth column, containing the actual gathered data
PYTHON_CSV_JOINER="import sys, csv
joined = csv.writer(sys.stdout)
with open(sys.argv[1]) as baseline:
    for wizerrow, row in zip(csv.reader(sys.stdin), csv.reader(baseline)):
        if wizerrow[:5] != row[:5]:
            raise Exception('Unexpected row order for ' + str(row) + ' and ' + str(wizerrow))

        joined.writerow(row + wizerrow[5:])
"
# Calculate the full time-to-interactive starting from the compilation and
# instantiation steps from the raw CSV from stdin
PYTHON_CSV_TIME_TO_INTERACTIVE_CALC="import csv, sys

VALID_STAGES = ['Compilation', 'Instantiation', 'Execution']

output = csv.writer(sys.stdout)

def reduce_rows(current_rows):
    # Create a lookup from each metric to its values for each valid step
    all_stages_for_each_metric = {}
    for current_row in current_rows:
        stage = current_row[5]
        if stage not in VALID_STAGES:
            raise Exception('Invalid stage: ' + str(stage))

        metric = all_stages_for_each_metric.get(current_row[6])
        if metric is None:
            all_stages_for_each_metric[current_row[6]] = {}
            all_stages_for_each_metric[current_row[6]][stage] = current_row[7]

        elif metric.get(stage) is not None:
            raise Exception('Stage ' + str(stage) + ' was declared multiple times for metric ' + str(current_row[6]))
        else:
            metric[stage] = current_row[7]

    for metric in all_stages_for_each_metric.keys():
        metric_values = all_stages_for_each_metric[metric]
        try:
            # Total metric from the instantiation step onward
            instantiation_value = int(metric_values['Instantiation']) + int(metric_values['Execution'])
            # Total metric from the compilation step onward
            compilation_value = int(metric_values['Compilation']) + instantiation_value
        except:
            raise Exception('Metric ' + str(metric) + ' is missing one of the stages ' + str(VALID_STAGES))

        output.writerow(current_rows[0][:5] + ['Compilation', metric, compilation_value])
        output.writerow(current_rows[0][:5] + ['Instantiation', metric, instantiation_value])

current_rows = []

header_skipped = False
for row in csv.reader(sys.stdin):
    if not header_skipped:
        # Assume first row is header
        output.writerow(row)
        header_skipped = True
        continue
    elif len(current_rows) == 0 or current_rows[-1][:5] == row[:5]:
        # Read all rows with the same process and iteration
        current_rows.append(row)
    else:
        # Once all those rows have been read, calculate and print the total compilation and instantiation time
        reduce_rows(current_rows)
        current_rows = [row]

reduce_rows(current_rows)
"

PROJECT_DIR=..
RESULT_TIME=$(date +"%F_%H%M%S")
RESULT_ROOT_DIR=_results
RESULT_DIR=$RESULT_ROOT_DIR/$RESULT_TIME
SIGHTGLASS="cargo +nightly run --bin sightglass-cli --"
ENGINE=./wasmtime
#SIGHTGLASS_OPTIONS="--engine $ENGINE -m perf-counters --raw --output-format csv"
SIGHTGLASS_OPTIONS="--engine $ENGINE --raw --output-format csv"
export RUST_LOG=debug

# If an engine is not available, build it.
if [[ ! -f $ENGINE ]]; then
    if [[ -n "$I_AM_MACOS" ]]; then
        ln -s $PROJECT_DIR/engines/wasmtime/libengine.dylib $ENGINE
    else
        ln -s $PROJECT_DIR/engines/wasmtime/libengine.so $ENGINE
    fi
fi
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
    RESULT_NAME_FULL=$RESULT_NAME.full
    RESULT_NAME_RAW=$RESULT_NAME.raw
    RESULT_NAME_WIZER_RAW=wizer.$RESULT_NAME_RAW

    # Produce raw and summarized results for the baseline
    rm -f "$TMP_RESULT"
    TMP_RESULT=$(mktemp /tmp/sightglass-benchmark-$RESULT_NAME-XXXXXX)
    $SIGHTGLASS benchmark $SIGHTGLASS_OPTIONS --working-dir $BENCH_DIR $BENCH_FILE | \
        # Prettify CSV
        sed -e 's/\.\///g' -e 's/\/benchmark\.wasm//g' | \
        # Tee raw results to file
        tee $RESULT_DIR/$RESULT_NAME_RAW | \
        # Summarize raw results and save to temporary file
        $SIGHTGLASS summarize -i csv -o csv > $TMP_RESULT

    # Produce raw and summarized results for the optimization
    $SIGHTGLASS benchmark $SIGHTGLASS_OPTIONS --working-dir $BENCH_DIR $BENCH_FILE_WIZER | \
        # Prettify CSV
        sed -e 's/\.\///g' -e 's/\/wizer\.benchmark\.wasm//g' | \
        # Tee raw results to file
        tee $RESULT_DIR/$RESULT_NAME_WIZER_RAW | \
        # Summarize raw results
        $SIGHTGLASS summarize -i csv -o csv | \
        # Join the summarized results row-wise with the results for the baseline
        python3 -c "$PYTHON_CSV_JOINER" "$TMP_RESULT" > $RESULT_DIR/$RESULT_NAME

    # Take the raw baseline and optimized results, calculate the
    # full time-to-interactive starting from the compilation and
    # instantiation steps, and produce summarized results
    rm -f "$TMP_RESULT_FULL"
    TMP_RESULT_FULL=$(mktemp /tmp/sightglass-benchmark-full-$RESULT_NAME-XXXXXX)
    cat $RESULT_DIR/$RESULT_NAME_RAW | \
        python3 -c "$PYTHON_CSV_TIME_TO_INTERACTIVE_CALC" | \
        $SIGHTGLASS summarize -i csv -o csv > "$TMP_RESULT_FULL"
    cat $RESULT_DIR/$RESULT_NAME_WIZER_RAW | \
        python3 -c "$PYTHON_CSV_TIME_TO_INTERACTIVE_CALC" | \
        $SIGHTGLASS summarize -i csv -o csv | \
        python3 -c "$PYTHON_CSV_JOINER" "$TMP_RESULT_FULL" > $RESULT_DIR/$RESULT_NAME_FULL

done

# Extract and save each step (for all benchmarks) to its own file
ALL_RESULTS=$(cat $RESULT_DIR/*.csv)
echo "$ALL_RESULTS" | grep Compilation | python3 -c "$PYTHON_CSV_SORTER" > $RESULT_DIR/__compilation.csv
echo "$ALL_RESULTS" | grep Instantiation | python3 -c "$PYTHON_CSV_SORTER" > $RESULT_DIR/__instantiation.csv
echo "$ALL_RESULTS" | grep Execution | python3 -c "$PYTHON_CSV_SORTER" > $RESULT_DIR/__execution.csv

# Extract and save the each time-to-interactive from a step (for all benchmarks) to its own file
ALL_RESULTS=$(cat $RESULT_DIR/*.csv.full)
echo "$ALL_RESULTS" | grep Compilation | python3 -c "$PYTHON_CSV_SORTER" > $RESULT_DIR/__full_compilation.csv
echo "$ALL_RESULTS" | grep Instantiation | python3 -c "$PYTHON_CSV_SORTER" > $RESULT_DIR/__full_instantiation.csv

# Update symlink pointing to latest result
rm -f $RESULT_ROOT_DIR/latest
ln -s $RESULT_TIME $RESULT_ROOT_DIR/latest
