#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/cmake-iwyu

IWYU_ARGS="include-what-you-use"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_INCLUDE_WHAT_YOU_USE=\"${IWYU_ARGS}\" \
                         ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR}