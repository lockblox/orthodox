#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/cmake-cpp-check

CPPCHECK_ARGS="cppcheck;\
--cppcheck-build-dir=${BUILDDIR};\
--suppressions-list=${SOURCEDIR}/.cpp-check-ignore;\
--inline-suppr;\
--error-exitcode=1;\
--force;\
--enable=all"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_CPPCHECK=\"${CPPCHECK_ARGS}\" ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR}