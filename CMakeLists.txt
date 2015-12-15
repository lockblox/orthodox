cmake_minimum_required(VERSION 2.8)

project(cpp-template)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
include_directories(${cpp-template_SOURCE_DIR}/include)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) #create compilation database for clang
set(Boost_USE_STATIC_LIBS ON)

find_package (
    Boost REQUIRED COMPONENTS filesystem system unit_test_framework program_options 
)
include_directories (${Boost_INCLUDE_DIRS})

add_library(libtemplate STATIC src/template.cpp)
set_target_properties(libtemplate PROPERTIES OUTPUT_NAME template)

add_executable(template src/main.cpp)
target_link_libraries(template ${Boost_LIBRARIES} libtemplate )

enable_testing()

file(GLOB TEST_SRCS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} test/*.cpp)

# Component test for whole executable
add_test (
    NAME BinTest WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin
    COMMAND template
)
set_tests_properties (
    BinTest PROPERTIES PASS_REGULAR_EXPRESSION
    "^Hello, world!"
    TIMEOUT 1
)

# Compile and run all unit tests
foreach(testSrc ${TEST_SRCS})
        #Extract the filename without an extension (NAME_WE)
        get_filename_component(testName ${testSrc} NAME_WE)

        add_executable(${testName} ${testSrc})

        target_link_libraries(${testName} ${Boost_LIBRARIES} libtemplate)

        set_target_properties(${testName} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/test)

        add_test(NAME ${testName}
                 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test
                 COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/test/${testName} )
endforeach(testSrc)
