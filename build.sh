#!/bin/bash

rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON
cmake --build build -j $(nproc)

./build/src/nvtop
