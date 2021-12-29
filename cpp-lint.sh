#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/cmake-cpp-lint

CPP_LINT_ARGS="cpplint"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_CPPLINT=\"${CPP_LINT_ARGS}\" \
                         ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR}