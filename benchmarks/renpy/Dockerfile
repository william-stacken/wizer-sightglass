FROM emscripten/emsdk:2.0.8
WORKDIR /

ENV BASE=.
ENV VENV="tmp/virtualenv.py3"
#RUN echo 'deb http://deb.debian.org/debian testing main' >> /etc/apt/sources.list
#RUN apt-get update && apt-get install -y sudo
#RUN git clone https://github.com/renpy/renpyweb
#WORKDIR /renpyweb
RUN git clone https://github.com/renpy/renpy-build
WORKDIR /renpy-build
RUN nightly/git.sh
RUN nightly/python.sh
RUN . tmp/virtualenv.py3/bin/activate
RUN ./build.py --platform web
WORKDIR /renpy-build/renpyweb
RUN make
RUN scripts/install_in_renpy.sh

#FROM emscripten/emsdk:2.0.8
#WORKDIR /
#COPY benchmark.c .
#COPY sightglass.h .
#COPY wizer.h .
#RUN emcc benchmark.c -O3 -g -DNDEBUG -I. -o benchmark.wasm
# We output the Wasm file to /benchmark.wasm, where the client expects it.

