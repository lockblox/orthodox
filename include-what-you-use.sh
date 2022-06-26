#!/bin/bash

set -u 

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/cmake-iwyu

IWYU_ARGS="include-what-you-use"
export CMAKE_CONFIG_ARGS="-DCMAKE_CXX_INCLUDE_WHAT_YOU_USE=\"${IWYU_ARGS}\" \
                         -DCMAKE_LINK_WHAT_YOU_USE_CHECK=TRUE
                         ${CMAKE_CONFIG_ARGS}"

logfile=`mktemp`
run_cmake ${BUILDDIR} | tee $logfile

cat ${logfile} | while read line;
do 
    echo ${line} | grep -v "Warning: include-what-you-use" > /dev/null
    if [ $? -ne 0 ];
    then
        exit 1
    fi
done