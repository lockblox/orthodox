FROM jbrooker/clang-toolchain:latest
MAINTAINER Jonathan Brooker <jonathan.brooker@gmail.com>

RUN apt-get install -yy --no-install-recommends libboost-test-dev
COPY . /home/cpp-template
WORKDIR /home/cpp-template
RUN cd build \
 && rm -rf * \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && scan-build make \
 && make test CTEST_OUTPUT_ON_FAILURE=TRUE 

