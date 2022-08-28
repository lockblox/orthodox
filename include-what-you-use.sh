#!/bin/bash

set -u 

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-iwyu

IWYU_ARGS="include-what-you-use"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_INCLUDE_WHAT_YOU_USE=\"${IWYU_ARGS}\" \
                         -DCMAKE_LINK_WHAT_YOU_USE_CHECK=TRUE
                         ${CMAKE_CONFIG_ARGS}"
export CMAKE_RUN_ARGS="--clean-first"

logfile=`mktemp`
run_cmake ${BUILDDIR} | tee $logfile

error_count=`grep "Warning: include-what-you-use" ${logfile} | wc -l`
rm ${logfile}

if [ ${error_count} -ne 0 ];
then
    exit 1
fi