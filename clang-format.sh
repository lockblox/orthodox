#!/bin/bash

INPLACE=0
while getopts i option
do
    case ${option} in
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

if [ $# -ne 2 ]; then
    echo "Usage: $0 [-i] SOURCE_DIR BUILD_DIR"
    exit 1
fi

SOURCE_DIR=$1
BUILD_DIR=$2

CLANG_FORMAT=`find ${SOURCE_DIR} -name .clang-format`
if [ ! -f ${CLANG_FORMAT} ]; then
    echo WARN: No .clang-format found in ${SOURCE_DIR}
else
    echo INFO: Using ${CLANG_FORMAT}
fi

# Find sources
TMP_FILENAME=`mktemp`

RETURN_CODE=0
SUBMODULES=`git -C ${SOURCE_DIR} submodule | sed 's/^ *//g' | cut -d " " -f 2`
for CPP_FILE in `grep '"file": ' ${BUILD_DIR}/compile_commands.json \
    | sed 's/^ *//g' | cut -d":" -f 2 | sed 's/^ *//g;s/^\"//g;s/\"$//g'`
do
    for SOURCE_FILE in ${CPP_FILE} `echo ${CPP_FILE} | sed 's/\.cpp/\.h/g'`
    do
        if [ ! -f ${SOURCE_FILE} ];
        then
            echo WARN: ${SOURCE_FILE} not found
            continue
        fi
        IS_EXTERNAL=0
        for MODULE in ${SUBMODULES}
        do
            echo ${SOURCE_FILE} | grep ${MODULE} >/dev/null
            if [ $? -eq 0 ];
            then
                IS_EXTERNAL=1;
            fi
        done

        if [ ${IS_EXTERNAL} -eq 1 ];
        then
            echo "Skipping external source file $SOURCE_FILE"
            continue
        fi

        # In-place formatting
        if [ ${INPLACE} -eq 1 ]; then
            clang-format -style=file -i "$SOURCE_FILE"
            if [ $? -ne 0 ]; then
                RETURN_CODE=1
            fi
            continue
        fi

        clang-format -style=file ${SOURCE_FILE} > ${TMP_FILENAME}
        diff ${SOURCE_FILE} ${TMP_FILENAME}
        if [ $? -ne 0 ]; then
          FILE_PATH=`echo ${SOURCE_FILE} | sed "s/.*\.\.\///g"`
          echo ERROR: ${FILE_PATH} 1>&2
          RETURN_CODE=1
        fi
        rm ${TMP_FILENAME}
    done
done

if [ ${RETURN_CODE} -ne 0 ]; then
    echo "The above files do not meet the coding standards."
    echo "Please run $0 -i to fix."
fi

exit ${RETURN_CODE}
