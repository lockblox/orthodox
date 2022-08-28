#!/bin/bash

TOOLS_DIR=`dirname $0` && \
${TOOLS_DIR}/asan.sh && \
${TOOLS_DIR}/clang.sh && \
${TOOLS_DIR}/clang-format.sh && \
${TOOLS_DIR}/clang-tidy.sh && \
${TOOLS_DIR}/coverage.sh && \
${TOOLS_DIR}/cpp-check.sh && \
${TOOLS_DIR}/cpp-lint.sh && \
${TOOLS_DIR}/gcc.sh && \
${TOOLS_DIR}/include-what-you-use.sh && \
${TOOLS_DIR}/scan-build.sh && \
${TOOLS_DIR}/valgrind.sh