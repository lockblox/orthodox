#!/bin/bash

TOOLS_DIR=`dirname $0`
TOOLS_DIR=`readlink -f ${TOOLS_DIR}`

if [ "${BUILDROOT}" == "" ];
then
   export BUILDROOT=/var/tmp
fi

if [ "${SOURCEDIR}" == "" ];
then
   export SOURCEDIR=/usr/local/src
fi

SANITIZER_BLACKLIST=${SOURCEDIR}/test/sanitizer-blacklist.txt
if [ ! -f ${SANITIZER_BLACKLIST} ]; then
    echo WARN: No sanitizer blacklist at ${SANITIZER_BLACKLIST}
    SANITIZER_BLACKLIST=${TOOLS_DIR}/test/sanitizer-blacklist.txt
fi
echo INFO: Using blacklist at ${SANITIZER_BLACKLIST}

export PROJECT=`basename ${SOURCEDIR}`
export CPUS=`lscpu | egrep "^CPU\(s\): *[0-9]" | tr -s " " | cut -d " " -f 2`
export CC=clang
export CXX=clang++
export CCC_CC=${CC}
export CCC_CXX=${CXX}
export NINJA=`which ninja`
export VCPKG_TOOLCHAIN="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
export VCPKG_INSTALLED_DIR="${BUILDROOT}"
export CMAKE_TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=${VCPKG_TOOLCHAIN}"
export CMAKE_EXPORT_COMMANDS="-DCMAKE_EXPORT_COMPILE_COMMANDS=1"
export CMAKE_CONFIG_ARGS="-DCMAKE_MAKE_PROGRAM=${NINJA} -GNinja"
export CMAKE_CONFIG_ARGS="${CMAKE_TOOLCHAIN} ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="${CMAKE_TOOLCHAIN} ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="-S ${SOURCEDIR} ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="-DCMAKE_BUILD_TYPE=Debug ${CMAKE_CONFIG_ARGS}"
export CMAKE_CONFIG_ARGS="$CMAKE_EXPORT_COMMANDS ${CMAKE_CONFIG_ARGS}"
export CMAKE="cmake"

function print_env()
{
    echo Tools directory is ${TOOLS_DIR}
    echo Source directory is ${SOURCEDIR}
    echo Build directory is ${BUILDDIR}
}

function run_cmake()
{
    BUILDDIR=$1
    COMMAND="${CMAKE} ${CMAKE_CONFIG_ARGS}"
    print_env
    echo Command is ${COMMAND}
    test -d ${BUILDDIR}/ || mkdir -pv ${BUILDDIR} \
    && cd ${BUILDDIR} \
    && eval ${COMMAND} \
    && ${CMAKE} --version \
    && ${CMAKE} --build ${BUILDDIR} --verbose --parallel ${CPUS} \
       ${CMAKE_RUN_ARGS}
}

function run_ctest()
{
   BUILDDIR=$1
   COMMAND="ctest -j ${CPUS} ${CTEST_ARGS}"
   echo Command is ${COMMAND}
   cd ${BUILDDIR} \
   && eval ${COMMAND}
}