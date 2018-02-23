
# orthodox

A docker container for performing quality assurance on c++ projects

Includes:
* Address, thread and undefined behaviour sanitizer builds
* clang-format format checking
* Scan-build static analysis
* clang-tidy coding style checker

# Example

docker run -v /my/source:/work/source \
           -v /my/build:/work/build \
           -it campx/orthodox

## License

MIT

## ROADMAP

* include-what-you-use
* fuzzing
