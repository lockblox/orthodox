FROM ubuntu:18.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential wget rsync cmake pkg-config perl-modules \
    libdigest-md5-file-perl xz-utils python \
    clang clang-tidy clang-format clang-tools git libstdc++-6-dev libssl-dev \
    ccache liblmdb-dev gdb llvm locate python-pip python-setuptools \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && updatedb \
 && pip install --user cpp-coveralls

ENV PATH="/root/.local/bin:/usr/lib/ccache:${PATH}"
COPY . /opt/orthodox
WORKDIR /root/build
ENTRYPOINT bash /opt/orthodox/build.sh /root/src
