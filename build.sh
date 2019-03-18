#!/bin/bash

# Usage: build.sh [SOURCE_DIR] [BUILD_DIR] [ROOT_DIR]

TOOLS_DIR=`dirname $0`
TOOLS_DIR=`readlink -f ${TOOLS_DIR}`
SOURCE_DIR=/root/src
ROOT_DIR=${SOURCE_DIR}
BUILD_DIR=/root/build

if [ $# -gt 0 ]; then
    SOURCE_DIR=`readlink -f $1`
fi
if [ $# -gt 1 ]; then
    BUILD_DIR=`readlink -f $2`
fi
if [ $# -gt 2 ]; then
    ROOT_DIR=`readlink -f $3`
fi

CPUS=`lscpu | egrep "^CPU\(s\): *[0-9]" | tr -s " " | cut -d " " -f 2`
echo Tools directory is ${TOOLS_DIR}
echo Source directory is ${SOURCE_DIR}
echo Root directory is ${ROOT_DIR}
echo Build directory is ${BUILD_DIR}

test -d ${SOURCE_DIR}/build || mkdir -v ${SOURCE_DIR}/build
test -d ${BUILD_DIR} || mkdir -v ${BUILD_DIR}
cd ${BUILD_DIR}


export CC=`which clang`
export CXX=`which clang++`
export CCC_CC=/usr/bin/clang
export CCC_CXX=/usr/bin/clang++
export LSAN_OPTIONS=verbosity=1:log_threads=1
export ASAN_SYMBOLIZER_PATH=`locate llvm-symbolizer | egrep "llvm-symbolizer$"`
export ASAN_OPTIONS=symbolize=1
export CTEST_OUTPUT_ON_FAILURE=1

SANITIZER_BLACKLIST=${SOURCE_DIR}/test/sanitizer-blacklist.txt
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
    -DCMAKE_CXX_COMPILER=/usr/share/clang/scan-build-6.0/libexec/c++-analyzer \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake \
 && echo Running scan-build \
 && time scan-build -o ${BUILD_DIR}/scan-build -V ninja -v \
 && test `ls -1 ${BUILD_DIR}/scan-build | wc -l` -eq 0 \
 && echo Running clang-format && ${TOOLS_DIR}/clang-format.sh ${SOURCE_DIR} \
    ${BUILD_DIR} \
 && rm -rf ${BUILD_DIR}/CMake* \
 && echo Building with address and undefined behaviour sanitizers \
 && cmake -GNinja -DCMAKE_CXX_FLAGS="${ASAN_FLAGS}" \
    -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake \
 && time ninja -v \
 && echo Running tests with address and undefined behaviour sanitizers \
 && time ninja -v test \
 && echo Running clang-tidy \
 && ${TOOLS_DIR}/clang-tidy.sh ${SOURCE_DIR} ${BUILD_DIR} \
 && cmake -GNinja -DCMAKE_CXX_FLAGS="${TSAN_FLAGS}" \
    -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
    -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake \
 && ninja clean \
 && echo Building with thread sanitizer \
 && time ninja -v \
 && echo Running tests with thread sanitizer \
 && time ninja -v test \
 && cd ${SOURCE_DIR}/build \
 && cmake \
    -GNinja \
    -DCMAKE_CXX_FLAGS="-O0 --coverage" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake \
    ${ROOT_DIR} \
 && echo Building with coverage \
 && time ninja -v \
 && echo Running tests with coverage \
 && time ninja -v test \
 && cd ${SOURCE_DIR} \
 && coveralls --gcov llvm-cov --gcov-options gcov --verbose \
              -E ".*gtest.*" -E ".*CMake.*" -E ".*test\/" \
              --build-root build \
 || true
