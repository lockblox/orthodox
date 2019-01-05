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
cd ${BUILD_DIR}

export CXX=`which clang++`
export LSAN_OPTIONS=verbosity=1:log_threads=1
export ASAN_SYMBOLIZER_PATH=`locate llvm-symbolizer | egrep "llvm-symbolizer$"`
export ASAN_OPTIONS=symbolize=1

SANITIZER_BLACKLIST=${SOURCE_DIR}/test/sanitizer-blacklist.txt
if [ ! -f ${SANITIZER_BLACKLIST} ]; then
    echo WARN: No sanitizer blacklist at ${SANITIZER_BLACKLIST}
    SANITIZER_BLACKLIST=${TOOLS_DIR}/test/sanitizer-blacklist.txt
fi
echo INFO: Using blacklist at ${SANITIZER_BLACKLIST}

echo Configuring build \
 && cmake -DCMAKE_CXX_FLAGS="-O1 -fsanitize=address,undefined \
    -fsanitize-blacklist=$SANITIZER_BLACKLIST \
    -fno-omit-frame-pointer -fno-optimize-sibling-calls" \
    -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
 && echo Running clang-format && ${TOOLS_DIR}/clang-format.sh ${SOURCE_DIR} \
    ${BUILD_DIR} \
 && echo Building with address and undefined behaviour sanitizers \
 && echo Running scan-build && time scan-build make -j ${CPUS} \
 && echo Running tests with address and undefined behaviour sanitizers \
 && time make test CTEST_OUTPUT_ON_FAILURE=TRUE \
 && echo Running clang-tidy && ${TOOLS_DIR}/clang-tidy.sh ${SOURCE_DIR} . \
 && cmake -DCMAKE_CXX_FLAGS="-O1 -fsanitize=thread -fno-omit-frame-pointer" \
    -fsanitize-blacklist=${SANITIZER_BLACKLIST} \
    -DCMAKE_BUILD_TYPE=Debug ${ROOT_DIR} \
 && make -j ${CPUS} clean \
 && echo Building with thread sanitizer \
 && time make -j ${CPUS} \
 && echo Running tests with thread sanitizer \
 && time make test CTEST_OUTPUT_ON_FAILURE=TRUE \
 && cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage -O0" \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ ${ROOT_DIR} \
 && echo Building with coverage \
 && time make -j ${CPUS} \
 && echo Running tests with coverage \
 && time make test CTEST_OUTPUT_ON_FAILURE=TRUE
