#!/bin/bash

if [ $# -ne 2 ];
then
    echo Usage: clang-tidy.sh SOURCE_DIR BUILD_DIR
    exit 1
fi

CLANG_TIDY=`locate run-clang-tidy.py 2>/dev/null`

for SEARCH_PATH in /usr/bin/ /usr/share/clang;
do
    if [ "$CLANG_TIDY" == "" ]; then
        CLANG_TIDY=`ls $SEARCH_PATH/run-clang-tidy*.py | head -1`
    fi
done

if [ "$CLANG_TIDY" == "" ]; then
    echo "ERROR: run-clang-tidy.py not found on system"
    exit -1
else
    echo "Using ${CLANG_TIDY}"
fi

# Find sources
SOURCE_DIR=`readlink -f $1`/
BUILD_DIR=$2

$CLANG_TIDY -p "$BUILD_DIR"

exit $?
