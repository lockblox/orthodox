#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

ASAN_FLAGS="-O1 -fsanitize=address,undefined"
ASAN_FLAGS="${ASAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls"
echo Using ASAN flags: ${ASAN_FLAGS}

export BUILDDIR=${BUILDROOT}/cmake-asan
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_FLAGS=\"${ASAN_FLAGS}\" ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR}