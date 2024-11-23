################################################################################
# Copyright (c) 2023-2024 Vladislav Trifochkin
#
# This file is part of `lorem-lib`.
#
# Changelog:
#       2023.04.25 Initial version.
#       2024.11.23 Up to C++14 standard.
#                  Removed `portable_target` dependency.
################################################################################
cmake_minimum_required (VERSION 3.19)
project(mime-ALL LANGUAGES CXX C)

option(MIME__BUILD_STRICT "Build with strict policies: C++ standard required, C++ extension is OFF etc" ON)
option(MIME__BUILD_TESTS "Build tests" OFF)

if (MIME__BUILD_STRICT)
    if (NOT CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD 14)
    endif()

    set(CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF) # use -std=c++XX rather than -std=gnu++XX
endif()

message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "C++ compiler version: ${CMAKE_CXX_COMPILER_VERSION}")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

include(${CMAKE_CURRENT_LIST_DIR}/library.cmake)

if (MIME__BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

include(GNUInstallDirs)

install(TARGETS mime
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
