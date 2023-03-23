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

RUN apt-get update && apt-get -y install xxd

# Build SpiderMonkey itself.
WORKDIR /usr/src
RUN git clone https://github.com/fastly/spidermonkey-wasi-embedding
WORKDIR /usr/src/spidermonkey-wasi-embedding
#RUN sh -c "echo 09c7bf1e7f9a87830f1f0568e82a012526cea1b7 > gecko-revision && echo 'https://github.com/william-stacken/gecko-dev' > gecko-repository"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install libxml2-dev m4
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
