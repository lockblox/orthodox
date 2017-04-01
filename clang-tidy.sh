#!/bin/bash

if [ $# -ne 2 ];
then
    echo Usage: clang-tidy.sh SOURCE_DIR BUILD_DIR
    exit 1
fi

CLANG_TIDY=`locate run-clang-tidy.py`
if [ "$CLANG_TIDY" == "" ]; then
    echo "ERROR: run-clang-tidy.py not found on system"
    exit -1
fi

# Find sources
SOURCE_DIR=`readlink -f $1`/
BUILD_DIR=$2
TMP_FILENAME=`mktemp`

RETURN_CODE=0

IGNORE_FILE="$SOURCE_DIR/test/clang-tidy.ignore"

if [ -f "$IGNORE_FILE" ];
then
    cp "$IGNORE_FILE" "$TMP_FILENAME"
else
    echo "WARN: Create $IGNORE_FILE with contents of errors you wish to supress"
fi

$CLANG_TIDY -p "$BUILD_DIR" -header-filter=".*" -checks=*,-llvm-header-guard \
    2>/dev/null \
    | egrep -o "\/.*" \
    | egrep "\..*:[0-9]+:" \
    | grep -v "note: " \
    | grep -v "googletest-src" \
    | sed "s|$SOURCE_DIR||g" \
    | grep -F -x -v -f "$TMP_FILENAME"

RETURN_CODE=$?

rm "$TMP_FILENAME"

if [ $RETURN_CODE -ne 0 ]; then
    RETURN_CODE=0
else
    RETURN_CODE=1
fi

exit $RETURN_CODE
