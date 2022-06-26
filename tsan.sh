#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

TSAN_FLAGS="-O1 -fsanitize=thread -fno-omit-frame-pointer"
TSAN_FLAGS="${TSAN_FLAGS} -fsanitize-blacklist=${SANITIZER_BLACKLIST}"

echo Using TSAN flags: ${TSAN_FLAGS}

export BUILDDIR=${BUILDROOT}/cmake-tsan
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_FLAGS=\"${TSAN_FLAGS}\" ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR}