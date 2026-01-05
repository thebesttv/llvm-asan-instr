#!/bin/bash

rm -rf build-release
mkdir build-release && cd build-release
cmake -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_TARGETS_TO_BUILD="Native" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      ${@} \
      ../llvm

      # -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt' \

# 打开对 typeid 的支持（感觉没用）
      # -DLLVM_ENABLE_RTTI=true \

#      -DLLVM_PARALLEL_COMPILE_JOBS=12 \
