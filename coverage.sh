#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

COV_FLAGS="-O0 --coverage"

echo Using COV flags: ${COV_FLAGS}

BUILDDIR=${BUILDROOT}/cmake-coverage
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_FLAGS=\"${COV_FLAGS}\" \
                          -DCMAKE_BUILD_TYPE=Debug \
                          ${CMAKE_CONFIG_ARGS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR} \
&& cd ${BUILDDIR} \
&& gcovr -r ${SOURCEDIR} --gcov-executable="llvm-cov gcov" --object-dir=. \
&& gcovr -r ${SOURCEDIR} --branches --gcov-executable="llvm-cov gcov" --object-dir=.