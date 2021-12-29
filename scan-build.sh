#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

export BUILDDIR=${BUILDROOT}/cmake-scan-build
export CMAKE="scan-build cmake"
run_cmake ${BUILDDIR}