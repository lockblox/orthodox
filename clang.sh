#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

echo Using CLANG flags: ${CLANG_FLAGS}

BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-clang
CLANG_FLAGS="--system-header-prefix=boost 
            -Weverything 
            -Werror 
            -Wno-c++98-compat 
            -Wno-c++98-compat-pedantic 
            -Wno-unknown-warning-option"

export CC=clang
export CXX=clang++
export CCC_CC=${CC}
export CCC_CXX=${CXX}
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_FLAGS=\"${CLANG_FLAGS}\" ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="-DCMAKE_THREAD_LIBS_INIT=\"-lpthread\" ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR}