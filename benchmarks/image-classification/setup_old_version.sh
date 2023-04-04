#!/bin/bash

# This will download a copy of OpenVINO and extract it locally, as well as the needed model files and test image. Once this script is run, you can use this command to run the benchmark:
# cargo run -- benchmark benchmarks/image-classification/image-classification-benchmark.wasm --engine-flags="--wasi-modules=experimental-wasi-nn" --engine engines/wasmtime/libengine.so

# EDIT: Modified this script to download an older version of OpenVINO that includes libinference_engine_c_api.so, this library is required by the ancient version on wasmtime (0.35.0) used
# by wizer

WASI_NN_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
FILENAME=l_openvino_toolkit_dev_ubuntu20_p_2021.3.394
MODEL=https://github.com/intel/openvino-rs/raw/main/crates/openvino/tests/fixtures/mobilenet
[ ! -d ${WASI_NN_DIR}/mobilenet.xml ] && wget -nc ${MODEL}/mobilenet.xml -O ${WASI_NN_DIR}/mobilenet.xml
[ ! -d ${WASI_NN_DIR}/mobilenet.bin ] && wget -nc -q --no-check-certificate ${MODEL}/mobilenet.bin -O ${WASI_NN_DIR}/mobilenet.bin
[ ! -d ${WASI_NN_DIR}/openvino ] && wget -nc -q --no-check-certificate https://storage.openvinotoolkit.org/repositories/openvino/packages/2021.3/${FILENAME}.tgz -O ${WASI_NN_DIR}/${FILENAME}.tgz
[ ! -d ${WASI_NN_DIR}/openvino ] && wget -nc -q --no-check-certificate https://storage.openvinotoolkit.org/repositories/openvino/packages/2021.3/${FILENAME}.tgz -O ${WASI_NN_DIR}/${FILENAME}.tgz
[ ! -d ${WASI_NN_DIR}/openvino ] && tar -C ${WASI_NN_DIR} -zxf ${WASI_NN_DIR}/${FILENAME}.tgz  && mv ${WASI_NN_DIR}/${FILENAME} ${WASI_NN_DIR}/openvino || echo "OpenVINO is already there, skipping..."