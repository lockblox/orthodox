#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

cd ${SOURCEDIR}
run-clang-format.py -j ${CPUS} -r ${PWD} $*
