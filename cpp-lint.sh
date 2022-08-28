#!/bin/bash

set -u 

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-cpp-lint

CPP_LINT_ARGS="cpplint;--quiet;--counting=detailed"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_CPPLINT=\"${CPP_LINT_ARGS}\" \
                         ${CMAKE_CONFIG_ARGS}"
export CMAKE_RUN_ARGS="--clean-first"

logfile=`mktemp`
run_cmake ${BUILDDIR} | tee $logfile

error_count=`grep "errors found" ${logfile} | wc -l`
rm ${logfile}

if [ ${error_count} -ne 0 ];
then
    exit 1
fi