cmake_minimum_required(VERSION 2.8)

project(cpp-template)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_CXX_FLAGS_MSAN "${CMAKE_CXX_FLAGS} -fsanitize=memory")
set(CMAKE_CXX_FLAGS_ASAN "${CMAKE_CXX_FLAGS} -fsanitize=address")
set(CMAKE_CXX_FLAGS_TSAN "${CMAKE_CXX_FLAGS} -fsanitize=thread")

include_directories(${cpp-template_SOURCE_DIR}/include)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) #create compilation database for clang
set(Boost_USE_STATIC_LIBS ON)

find_package(Boost REQUIRED COMPONENTS unit_test_framework)
include_directories (${Boost_INCLUDE_DIRS})

add_library(libtemplate STATIC src/template.cpp)
set_target_properties(libtemplate PROPERTIES OUTPUT_NAME template)

add_executable(template src/main.cpp)
target_link_libraries(template ${Boost_LIBRARIES} libtemplate )

enable_testing()

string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" LINUX)
if(LINUX)
    # Test code formatting obeys convention
    add_test ( 
        NAME ClangFormat WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test
        COMMAND clang-format.sh
    )
    # Test code style obeys convention
    add_test ( 
        NAME ClangTidy WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test
        COMMAND clang-tidy.sh
    )
ENDIF(LINUX) 


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
file(GLOB TEST_SRCS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} test/*.cpp)
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
