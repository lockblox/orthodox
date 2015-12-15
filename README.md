[![Build Status](https://travis-ci.org/jbrooker/cpp-template.svg?branch=master)](https://travis-ci.org/jbrooker/cpp-template)

# cpp-template

A skeleton project for c++ projects, based on cmake.

Includes 
* CMakeLists.txt with targets for a library, executable, and unit tests
* Coding standards expressed as a .clang-format file
* Travis CI config in .travis.yml with OS X and Linux/Docker targets

## Example

Run [bin/template](src/main.cpp)

```
cd build
cmake ..
make
../bin/template
Hello, world!
```

## License

MIT
