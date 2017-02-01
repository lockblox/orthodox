#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: build.sh [SOURCE_DIR]"
    exit 1
fi

TOOLS_DIR=`dirname $0`
TOOLS_DIR=`readlink -f $TOOLS_DIR`
SOURCE_DIR=$1
SOURCE_DIR=`readlink -f $SOURCE_DIR`
CPUS=`lscpu | egrep "^CPU\(s\): *[0-9]" | tr -s " " | cut -d " " -f 2`
echo Source directory is $SOURCE_DIR

export CXX=`which clang++`

SANITIZER_BLACKLIST=$SOURCE_DIR/test/sanitizer-blacklist.txt
if [ ! -f $SANITIZER_BLACKLIST ]; then
    echo WARN: No sanitizer blacklist at $SANITIZER_BLACKLIST
    SANITIZER_BLACKLIST=`mktemp`
fi

export ASAN_SYMBOLIZER_PATH=`locate llvm-symbolizer | egrep "llvm-symbolizer$"`

echo Configuring build \
 && cmake -DCMAKE_CXX_FLAGS="-O1 -fsanitize=address,undefined \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -fsanitize-blacklist=$SOURCE_DIR/test/sanitizer-blacklist.txt \
    -fno-omit-frame-pointer" -DCMAKE_BUILD_TYPE=Debug $SOURCE_DIR \
 && echo Running clang-format && $TOOLS_DIR/clang-format.sh $SOURCE_DIR \
 && echo Running clang-tidy && $TOOLS_DIR/clang-tidy.sh $SOURCE_DIR . \
 && echo Building with address and undefined behaviour sanitizers \
 && echo Running scan-build && time scan-build make -j $CPUS \
 && echo Running tests with address and undefined behaviour sanitizers \
 && time make test CTEST_OUTPUT_ON_FAILURE=TRUE \
 && cmake -DCMAKE_CXX_FLAGS="-O1 -fsanitize=thread -fno-omit-frame-pointer" \
    -fsanitize-blacklist=$SOURCE_DIR/test/sanitizer-blacklist.txt \
    -DCMAKE_BUILD_TYPE=Debug $SOURCE_DIR \
 && make -j $CPUS clean \
 && echo Building with thread sanitizer \
 && time make -j $CPUS \
 && echo Running tests with thread sanitizer \
 && time make test CTEST_OUTPUT_ON_FAILURE=TRUE \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="--coverage" \
    $SOURCE_DIR \
 && echo Running production build && time make -j $CPUS
