FROM ubuntu:jammy
WORKDIR /

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends git make sudo tzdata lsb-release software-properties-common

RUN git clone https://github.com/renpy/renpy-build
WORKDIR /renpy-build

RUN ./prepare.sh

RUN mkdir -p tmp/install.web-wasm/include/
COPY Live2DCubismCore.h tmp/install.web-wasm/include/
RUN . tmp/virtualenv.py3/bin/activate && ./build.py --platform web

RUN cp renpy/web3/renpy.wasm /benchmark.wasm

# Packaging test game can be done like this (assuming lib directory has been installed using renpyweb/scripts/distribute_game.sh)
#RUN python3 renpy/renpy.py renpy/launcher distribute --package web --packagedest renpy/web3/game renpy/the_question

# TODO Do we need to run the makefile in the renpyweb repository or not?
# inittab.c is missing from renpyweb, but it can be found in renpy-build?
#RUN cp tmp/build/librenpy.web-wasm-py3/inittab.c renpyweb
#WORKDIR /renpy-build/renpyweb

# Load the emscripten sdk into PATH
#RUN source "/renpy-build/tmp/cross.web-wasm/emsdk_env.sh"
# Symlink dependencies from renpy-build into renpyweb
#RUN ln -s ../renpy renpy && ln -s ../pygame_sdl2 pygame_sdl2
#RUN make
#RUN scripts/install_in_renpy.sh
