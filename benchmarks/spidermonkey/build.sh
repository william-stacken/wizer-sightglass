#!/bin/sh

set -x -e

SM=/usr/src/spidermonkey-wasi-embedding

xxd -i js/marked.min.js > marked_js.h
xxd -i js/main.js > main_js.h

/opt/wasi-sdk/bin/clang++ -g --sysroot=/opt/wasi-sdk/share/wasi-sysroot -DDEBUG -D_WASI_EMULATED_GETPID -O3 -std=c++17 -o /benchmark.wasm runtime.cpp -I. -I$SM/debug/include/ $SM/debug/lib/*.o $SM/debug/lib/*.a -lwasi-emulated-getpid

/opt/wasi-sdk/bin/strip /benchmark.wasm
