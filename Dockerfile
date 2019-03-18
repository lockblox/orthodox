FROM ubuntu:18.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    rsync \
    curl \
    locate \
    pkg-config \
    perl-modules \
    unzip \
    tar \
    xz-utils \
    python \
    python-pip \
    git \
    gdb \
    llvm \
    cmake \
    ccache \
    clang \
    clang-tidy \
    clang-format \
    clang-tools \
    ninja-build \
    libdigest-md5-file-perl \
    libstdc++-6-dev \
    libssl-dev \
    liblmdb-dev \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && updatedb \
 && python -m pip install --upgrade pip \
 && pip install requests \
 && pip install setuptools \
 && pip install wheel \
 && pip install pyyaml \
 && pip install cpp-coveralls \
 && git clone https://github.com/Microsoft/vcpkg.git \
 && cd vcpkg \
 && ./bootstrap-vcpkg.sh \
 && ./vcpkg integrate install \
 && ./vcpkg install gtest

WORKDIR /root/build
ENV PATH="/usr/lib/ccache:${PATH}"
COPY . /opt/orthodox
ENTRYPOINT bash /opt/orthodox/build.sh /root/src