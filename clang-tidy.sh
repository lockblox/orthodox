#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-clang-tidy

export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_CLANG_TIDY=clang-tidy ${CMAKE_CONFIG_ARGS}"
run_cmake ${BUILDDIR}