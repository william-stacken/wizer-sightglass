FROM ubuntu:20.04

RUN apt-get update
RUN apt-get -y install git python3 python3-pip python3-distutils curl sudo 
RUN curl https://sh.rustup.rs | bash -s - -y
ENV PATH=/root/.cargo/bin:$PATH

RUN apt-get -y install wget
WORKDIR /opt
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-14/wasi-sdk-14.0-linux.tar.gz
RUN tar zxvf wasi-sdk-14.0-linux.tar.gz
RUN ln -s wasi-sdk-14.0 wasi-sdk

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install xxd libxml2-dev m4

# Build SpiderMonkey itself.
WORKDIR /usr/src
RUN git clone https://github.com/fastly/spidermonkey-wasi-embedding
WORKDIR /usr/src/spidermonkey-wasi-embedding
RUN ./build-engine.sh

WORKDIR /usr/src

RUN mkdir benchmark && cd benchmark/

COPY wizer.h .
COPY sightglass.h .

RUN mkdir js
COPY js/marked.min.js js/marked.min.js
COPY js/main.js js/main.js

COPY build.sh .
COPY runtime.cpp .

RUN ./build.sh
