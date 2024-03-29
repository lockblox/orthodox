#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

ASAN_FLAGS="-O1 -fsanitize=address,undefined"
ASAN_FLAGS="${ASAN_FLAGS} -fsanitize-blacklist=${SANITIZER_BLACKLIST}"
ASAN_FLAGS="${ASAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls -Wno-unknown-warning-option"

echo Using ASAN flags: ${ASAN_FLAGS}

export ANALYZER=`locate c++-analyzer | egrep "c\+\+-analyzer$" | head -1`
export LSAN_OPTIONS=verbosity=1:log_threads=1
export ASAN_SYMBOLIZER_PATH=`locate llvm-symbolizer | egrep "llvm-symbolizer$" | head -1`
export BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-asan
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_FLAGS=\"${ASAN_FLAGS}\" ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_COMPILER=${ANALYZER} ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR}