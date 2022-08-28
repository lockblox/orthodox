#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

export SCAN_BUILD=`locate scan-build | egrep "scan-build$" | head -1`
export BUILDDIR=${BUILDROOT}/${PROJECT}-cmake-scan-build
export CMAKE="${SCAN_BUILD} cmake"
run_cmake ${BUILDDIR}