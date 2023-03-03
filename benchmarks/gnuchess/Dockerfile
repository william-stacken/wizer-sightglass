# This two-phase Dockerfile allows us to avoid re-downloading APT packages and wasi-sdk with every
# build.

# First, retrieve wasi-sdk:

FROM ubuntu:18.04 AS builder
WORKDIR /
RUN apt-get update && apt-get install -y wget

# Download and extract wasi-sdk.
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-12.0-linux.tar.gz
RUN tar xvf wasi-sdk-12.0-linux.tar.gz

# Second, compile the benchmark to Wasm.

FROM ubuntu:18.04
WORKDIR /
COPY --from=builder /wasi-sdk-12.0 /wasi-sdk-12.0/

# Set common env vars.
ENV CC=/wasi-sdk-12.0/bin/clang
ENV CXX=/wasi-sdk-12.0/bin/clang++
ENV LD=/wasi-sdk-12.0/bin/lld
ENV CFLAGS=--sysroot=/wasi-sdk-12.0/share/wasi-sysroot
ENV CXXFLAGS=--sysroot=/wasi-sdk-12.0/share/wasi-sysroot
ENV PATH /wasi-sdk-12.0

# Compile `benchmark.c` to `./benchmark.wasm`.
COPY src/ .
RUN $CC $CFLAGS src/*.c -O3 -g -DNDEBUG -Isrc -o benchmark.wasm
