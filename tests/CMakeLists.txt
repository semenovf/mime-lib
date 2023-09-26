################################################################################
# Copyright (c) 2023 Vladislav Trifochkin
#
# This file is part of [mime-lib](https://github.com/semenovf/common-lib) library.
################################################################################
project(mime-TESTS CXX C)

if (MIME__ENABLE_COVERAGE)
    message(STATUS "Coverage feature enabled")
    if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        message(FATAL_ERROR "Coverage feature requires GCC")
    endif()

    set(CMAKE_CXX_FLAGS "-g -O0 --coverage")
    set(CMAKE_C_FLAGS "-g -O0 --coverage")
endif()

if (TARGET pfs::mime)
    set(_mime_lib pfs::mime)
elseif(TARGET pfs::mime::static)
    set(_mime_lib pfs::mime::static)
endif()

set(TEST_NAMES
    mime_by_extension)

foreach (name ${TEST_NAMES})
    if (${name}_SOURCES)
        add_executable(${name} ${${name}_SOURCES} ${name}.cpp)
    else ()
        add_executable(${name} ${name}.cpp)
    endif()

    # https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#Instrumentation-Options
    #
    # --coverage
    #       This option is used to compile and link code instrumented for
    #       coverage analysis. The option is a synonym for -fprofile-arcs
    #       -ftest-coverage (when compiling) and -lgcov (when linking).
    if (MIME__ENABLE_COVERAGE)
        target_compile_options(${name} PRIVATE -g -O0 --coverage)
        target_link_libraries(${name} PRIVATE -g -O0 --coverage)
    endif()

    target_link_libraries(${name} PRIVATE ${_mime_lib})
    add_test(NAME ${name} COMMAND ${name})
endforeach()

if (MIME__ENABLE_COVERAGE)
    coverage_target("'/usr/*';'*/doctest.h'")
endif()
