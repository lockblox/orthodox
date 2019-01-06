FROM ubuntu:18.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    rsync \
    locate \
    pkg-config \
    perl-modules \
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
    libdigest-md5-file-perl \
    libstdc++-6-dev \
    libssl-dev \
    liblmdb-dev \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && updatedb

RUN python -m pip install --upgrade pip \
 && pip install requests \
 && pip install setuptools \
 && pip install wheel \
 && pip install cpp-coveralls

ENV PATH="/usr/lib/ccache:${PATH}"
COPY . /opt/orthodox
WORKDIR /root/build
ENTRYPOINT bash /opt/orthodox/build.sh /root/src
