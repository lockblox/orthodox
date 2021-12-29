#!/bin/bash

TOOLSDIR=`dirname $0`
source ${TOOLSDIR}/common.sh

BUILDDIR=${BUILDROOT}/cmake-valgrind

export MEMORYCHECK_COMMAND=`which valgrind`
export MEMORYCHECK_COMMAND_OPTIONS="--leak-check=yes --show-reachable=yes --trace-children=yes --num-callers=20 --track-fds=yes"
export CTEST_ARGS="-D ExperimentalMemCheck --overwrite MemoryCheckCommand=${MEMORYCHECK_COMMAND} --overwrite MemoryCheckCommandOptions=${MEMORYCHECK_COMMAND_OPTIONS}"

run_cmake ${BUILDDIR} \
&& run_ctest ${BUILDDIR}