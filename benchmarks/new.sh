#!/usr/bin/env bash


DOCKERFILE_SUFFIX="${2:-wasi-sdk}"
DOCKERFILE="Dockerfile.$DOCKERFILE_SUFFIX"
if [[ ! -f $DOCKERFILE ]]; then
    echo "Dockerfile for the given suffix does not exist; usage: ./new.sh <path to benchmark directory> [<dockerfile suffix>]"
    exit 1
fi

BENCHMARK_DIR=$1
if [[ -z "$BENCHMARK_DIR" ]]; then
    echo "Benchmark directory not specified; usage: ./new.sh <path to benchmark directory> [<dockerfile suffix>]"
    exit 1
fi

if [[ $(basename "$BENCHMARK_DIR") != "$BENCHMARK_DIR" ]]; then
    echo "Benchmark directory depth cannot be more than 1; usage: ./new.sh <path to benchmark directory> [<dockerfile suffix>]"
    exit 1
fi

mkdir -p $BENCHMARK_DIR

ln -s ../$DOCKERFILE $BENCHMARK_DIR/Dockerfile 2>/dev/null
ln -s ../Dockerfile.wizer-wasi $BENCHMARK_DIR/Dockerfile.wizer 2>/dev/null
ln -s ../../include/sightglass.h $BENCHMARK_DIR/sightglass.h 2>/dev/null
ln -s ../../wizer/include/wizer.h $BENCHMARK_DIR/wizer.h 2>/dev/null
touch $BENCHMARK_DIR/stderr.expected
touch $BENCHMARK_DIR/stdout.expected
