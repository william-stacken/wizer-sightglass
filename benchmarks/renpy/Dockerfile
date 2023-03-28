FROM emscripten/emsdk:3.1.34
WORKDIR /

#RUN echo 'deb http://deb.debian.org/debian testing main' >> /etc/apt/sources.list
#RUN apt-get update && apt-get install -y sudo
#RUN git clone https://github.com/renpy/renpyweb
#WORKDIR /renpyweb
RUN git clone https://github.com/renpy/renpy-build
WORKDIR /renpy-build
#ENV BASE=/renpy-build
#ENV ROOT=/renpy-build
#ENV VENV=/renpy-build/tmp/virtualenv.py3
#ENV RENPY_DEPS_INSTALL=/usr::/usr/lib/x86_64-linux-gnu/
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends sudo tzdata lsb-release software-properties-common
RUN ./prepare.sh
#RUN bash nightly/git.sh

#ENV CFLAGS="$CFLAGS -I$VENV/include/python3.8m"
#RUN python3 -m venv -p python3.8 $VENV
#RUN . $VENV/bin/activate && pip install wheel8


#RUN bash nightly/python.sh
RUN . tmp/virtualenv.py3/bin/activate && ./build.py --platform web
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

