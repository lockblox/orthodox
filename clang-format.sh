#!/bin/bash

INPLACE=0
while getopts i option
do
    case $option in 
    i)  INPLACE=1
        ;;
    *)  echo "Usage $0 [-i]"
        echo "OPTIONS:"
        echo       -i: Format files according to coding standards in place
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))

if [ $# -ne 1 ]; then
    echo "Usage: $0 [-i] SOURCE_DIR"
    exit 1
fi

SOURCE_DIR=$1

CLANG_FORMAT=`find $SOURCE_DIR -name .clang-format`
if [ ! -f $CLANG_FORMAT ]; then
    echo WARN: No .clang-format found in $SOURCE_DIR
fi

# Find sources
BUILD_DIR="$PWD"
TMP_FILENAME=`mktemp`

RETURN_CODE=0

for SOURCE_FILE in `find "$SOURCE_DIR" -name "*.cpp" -o -name "*.h"` 
do
    # In-place formatting
    if [ $INPLACE -eq 1 ]; then
        clang-format -style=file -i "$SOURCE_FILE"
        if [ $? -ne 0 ]; then
            RETURN_CODE=1
        fi
        continue
    fi

    clang-format -style=file "$SOURCE_FILE" > "$TMP_FILENAME"
    diff "$SOURCE_FILE" "$TMP_FILENAME"
    if [ $? -ne 0 ]; then
        FILEPATH=`echo "$SOURCE_FILE" | sed "s/.*\.\.\///g"`
      echo "$FILEPATH" 1>&2
      RETURN_CODE=1
    fi
    rm $TMP_FILENAME
done

if [ $RETURN_CODE -ne 0 ]; then
    echo "The above files do not meet the coding standards."
    echo "Please run $0 -i to remediate."
fi

exit $RETURN_CODE
