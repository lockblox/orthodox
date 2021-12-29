#!/bin/bash

# Usage: build.sh [SOURCEDIR] [BUILDDIR] [ROOT_DIR]

TOOLS_DIR=`dirname $0`
TOOLS_DIR=`readlink -f ${TOOLS_DIR}`

if [ "${BUILDDIR}" == "" ];
then
   export BUILDDIR=/var/tmp/build
fi

echo Source directory is ${SOURCEDIR}

if [ "${SOURCEDIR}" == "" ];
then
   export SOURCEDIR=/usr/local/src
fi

export ROOT_DIR=${SOURCEDIR}

if [ $# -gt 0 ]; then
    export SOURCEDIR=`readlink -f $1`
fi
if [ $# -gt 1 ]; then
    export BUILDDIR=`readlink -f $2`
fi
if [ $# -gt 2 ]; then
    export ROOT_DIR=`readlink -f $3`
fi

CPUS=`lscpu | egrep "^CPU\(s\): *[0-9]" | tr -s " " | cut -d " " -f 2`
echo Tools directory is ${TOOLS_DIR}
echo Source directory is ${SOURCEDIR}
echo Root directory is ${ROOT_DIR}
echo Build directory is ${BUILDDIR}

test -d ${SOURCEDIR}/build || mkdir -v ${SOURCEDIR}/build
test -d ${BUILDDIR} || mkdir -v ${BUILDDIR}
cd ${BUILDDIR}

export CC=clang
export CXX=clang++
export CCC_CC=${CC}
export CCC_CXX=${CXX}
export LSAN_OPTIONS=verbosity=1:log_threads=1
export ASAN_SYMBOLIZER_PATH=`locate llvm-symbolizer | egrep "llvm-symbolizer$" | head -1`
export ASAN_OPTIONS=symbolize=1
export CTEST_OUTPUT_ON_FAILURE=1
export ANALYZER=`locate c++-analyzer | egrep "c\+\+-analyzer$" | head -1`
export SCAN_BUILD=`locate scan-build | egrep "scan-build$" | head -1`
export VCPKG_TOOLCHAIN="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
export CMAKE_TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=${VCPKG_TOOLCHAIN}"
export CMAKE_CONFIG_ARGS="${CMAKE_TOOLCHAIN} ${CMAKE_CONFIG_ARGS}"

${TOOLS_DIR}/cpp-check.sh

SANITIZER_BLACKLIST=${SOURCEDIR}/test/sanitizer-blacklist.txt
if [ ! -f ${SANITIZER_BLACKLIST} ]; then
    echo WARN: No sanitizer blacklist at ${SANITIZER_BLACKLIST}
    SANITIZER_BLACKLIST=${TOOLS_DIR}/test/sanitizer-blacklist.txt
fi
echo INFO: Using blacklist at ${SANITIZER_BLACKLIST}

TSAN_FLAGS="-O1 -fsanitize=thread -fno-omit-frame-pointer"
TSAN_FLAGS="${TSAN_FLAGS} -fsanitize-blacklist=${SANITIZER_BLACKLIST}"
echo Using TSAN flags: ${TSAN_FLAGS}
ASAN_FLAGS="-O1 -fsanitize=address,undefined"
ASAN_FLAGS="${ASAN_FLAGS} -fsanitize-blacklist=${SANITIZER_BLACKLIST}"
ASAN_FLAGS="${ASAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls"
echo Using ASAN flags: ${ASAN_FLAGS}

echo Configuring build \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
    -DCMAKE_CXX_COMPILER=${ANALYZER} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    ${CMAKE_CONFIG_ARGS} \
 && echo Building with address and undefined behaviour sanitizers \
 && cmake -GNinja -DCMAKE_CXX_FLAGS="${ASAN_FLAGS}" \
    -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    ${CMAKE_CONFIG_ARGS} \
 && time ninja -v \
 && echo Running tests with address and undefined behaviour sanitizers \
 && time ninja -v test \
 && echo Running clang-tidy \
 && ${TOOLS_DIR}/clang-tidy.sh ${SOURCEDIR} ${BUILDDIR} \
 && cmake -GNinja -DCMAKE_CXX_FLAGS="${TSAN_FLAGS}" \
    -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
    ${CMAKE_CONFIG_ARGS} \
 && ninja clean \
 && echo Building with thread sanitizer \
 && time ninja -v \
 && echo Running tests with thread sanitizer \
 && time ninja -v test \
 && cd ${SOURCEDIR}/build \
 && cmake \
    -GNinja \
    -DCMAKE_CXX_FLAGS="-O0 --coverage" \
    -DCMAKE_BUILD_TYPE=Debug \
    ${CMAKE_CONFIG_ARGS} \
    ${ROOT_DIR} \
 && echo Building with coverage \
 && time ninja -v \
 && echo Running tests with coverage \
 && time ninja -v test \
 && cd ${SOURCEDIR} \
 && (coveralls --gcov llvm-cov --gcov-options gcov --verbose \
              -E ".*gtest.*" -E ".*CMake.*" -E ".*test\/" \
              --build-root build \
 || gcovr -r ${ROOT_DIR} --gcov-executable="llvm-cov gcov") \
 && cd ${BUILDDIR} \
 && ninja install
