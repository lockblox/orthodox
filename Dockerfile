FROM ubuntu:22.04

ENV CLANG_VERSION=15
ENV GCC_VERSION=12

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
 apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    rsync \
    curl \
    locate \
    pkg-config \
    perl-modules \
    unzip \
    tar \
    zip \
    vim \
    xz-utils \
    python3 \
    python3-pip \
    python-is-python3 \
    gcc-${GCC_VERSION} \
    g++-${GCC_VERSION} \
    libstdc++-${GCC_VERSION}-dev \
    libc++-${GCC_VERSION}-dev \
    git \
    gdb \
    gcovr \
    ccache \
    distcc \
    cmake \
    cppcheck \
    clang-${CLANG_VERSION} \
    clangd-${CLANG_VERSION} \
    clang-tidy-${CLANG_VERSION} \
    clang-format-${CLANG_VERSION} \
    clang-tools-${CLANG_VERSION} \
    llvm-${CLANG_VERSION}-dev \
    libclang-${CLANG_VERSION}-dev \
    ninja-build \
    valgrind \
    libdigest-md5-file-perl \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && updatedb

RUN ln -s /usr/bin/clang-${CLANG_VERSION} \
         /usr/bin/clang \
 && ln -s /usr/bin/clang++-${CLANG_VERSION} \
         /usr/bin/clang++ \
 && ln -s /usr/bin/clang-tidy-${CLANG_VERSION} \
         /usr/bin/clang-tidy \
 && ln -s /usr/bin/clang-format-${CLANG_VERSION} \
         /usr/bin/clang-format \
 && cd /usr/lib/llvm-${CLANG_VERSION}/share/clang \
 && wget https://raw.githubusercontent.com/Sarcasm/run-clang-format/master/run-clang-format.py \
 && chmod +x /usr/lib/llvm-${CLANG_VERSION}/share/clang/run-clang-format.py \
 && cd /usr/bin \
 && ln -s ../lib/llvm-${CLANG_VERSION}/share/clang/run-clang-tidy.py \
         run-clang-tidy.py \
 && ln -s ../lib/llvm-${CLANG_VERSION}/share/clang/run-clang-format.py \
         run-clang-format.py \
 && cd /usr/local/src \
 && git clone https://github.com/include-what-you-use/include-what-you-use.git \
 && cd include-what-you-use \
 && git checkout clang_${CLANG_VERSION} \
 && mkdir build \
 && cd build \
 && cmake -GNinja -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${CLANG_VERSION} .. \
 && ninja install

RUN python3 -m pip install --upgrade pip \
 && pip install requests \
 && pip install setuptools \
 && pip install wheel \
 && pip install pyyaml \
 && pip install cpplint \
 && pip install cpp-coveralls \
 && pip install cmake-format

ENV PATH="/usr/lib/ccache:/usr/lib/llvm-${CLANG_VERSION}/bin:/usr/share/orthodox:${PATH}"
ENV SOURCEDIR="/usr/local/src/"
ENV BUILDROOT="/var/tmp"
WORKDIR /var/tmp/build
COPY . /usr/share/orthodox
ENTRYPOINT bash /usr/share/orthodox/all.sh