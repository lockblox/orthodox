#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

echo Using GCC flags: ${GCC_FLAGS}

BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-gcc
GCC_FLAGS=" -O1 \
            -Wall \
            -Wextra \
            -Wshadow \
            -Wnon-virtual-dtor \
            -pedantic \
            -Werror \
            -Wold-style-cast \
            -Wcast-align \
            -Wunused \
            -Woverloaded-virtual \
            -Wpedantic \
            -Wconversion \
            -Wsign-conversion \
            -Wmisleading-indentation \
            -Wduplicated-cond \
            -Wduplicated-branches \
            -Wlogical-op \
            -Wnull-dereference \
            -Wuseless-cast \
            -Wdouble-promotion \
            -Wformat=2 \
            -Wno-unknown-pragmas"

export CC=gcc
export CXX=g++
export CCC_CC=${CC}
export CCC_CXX=${CXX}
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_FLAGS=\"${GCC_FLAGS}\" ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="-DCMAKE_THREAD_LIBS_INIT=\"-lpthread\" ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR}