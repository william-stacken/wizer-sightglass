FROM rust:1.67

RUN rustup default nightly && rustup update
RUN rustup target add wasm32-wasi
WORKDIR /usr/src
ADD rust-benchmark rust-benchmark
WORKDIR /usr/src/rust-benchmark
# Increase Wasm memory to contain the model weights, input image, etc
ENV RUSTFLAGS="-Clink-arg=--initial-memory=67108864 -Clink-arg=--max-memory=67108864"
RUN cargo build --release --target wasm32-wasi
RUN cp target/wasm32-wasi/release/*.wasm /benchmark.wasm
# We output the Wasm file to /benchmark.wasm, where the client expects it.
