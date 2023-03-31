# This two-phase Dockerfile allows us to avoid re-downloading APT packages and wasi-sdk with every
# build.

# First, retrieve wasi-sdk:

FROM ubuntu:18.04 AS builder
WORKDIR /
RUN apt-get update && apt-get install -y wget

# Download and extract wasi-sdk.
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-14/wasi-sdk-14.0-linux.tar.gz
RUN tar xvf wasi-sdk-14.0-linux.tar.gz

# Second, compile the benchmark to Wasm.

FROM ubuntu:18.04
WORKDIR /
COPY --from=builder /wasi-sdk-14.0 /wasi-sdk/

# Set common env vars.
ENV CC=/wasi-sdk/bin/clang
ENV CXX=/wasi-sdk/bin/clang++
ENV LD=/wasi-sdk/bin/lld
ENV CFLAGS="--sysroot=/wasi-sdk/share/wasi-sysroot"
ENV CXXFLAGS='--sysroot=/wasi-sdk/share/wasi-sysroot -D_WASI_EMULATED_SIGNAL -fno-exceptions -DPATH_ESPEAK_DATA="./espeak-data" -lwasi-emulated-signal -Wwritable-strings'
ENV PATH /wasi-sdk

# Compile `benchmark.c` to `./benchmark.wasm`.
COPY src/ .
COPY sightglass.h .
COPY wizer.h .
RUN $CXX $CXXFLAGS $(/bin/ls *.cpp) -O3 -g -DNDEBUG -I. -o benchmark.wasm
