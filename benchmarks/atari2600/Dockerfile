FROM node:16.20.0-alpine

RUN apk update && apk add git
RUN git clone https://github.com/ColinEberhardt/atari2600-wasm
WORKDIR /atari2600-wasm
COPY package.json package.json
COPY index.ts assembly/index.ts
RUN npm install
RUN npx asc assembly/index.ts -b benchmark.wasm -O3z --initialMemory 10 --use abort= --use trace=assembly/index/stubTrace
RUN mv benchmark.wasm /benchmark.wasm
