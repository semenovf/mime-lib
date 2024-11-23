################################################################################
# Copyright (c) 2023-2024 Vladislav Trifochkin
#
# This file is part of `mime-lib`.
#
# Changelog:
#       2023.05.02 Initial version.
#       2024.11.23 Removed `portable_target` dependency.
################################################################################
cmake_minimum_required (VERSION 3.19)
project(mime LANGUAGES C CXX)

option(MIME__BUILD_SHARED "Enable build shared library" OFF)

if (MIME__BUILD_SHARED)
    add_library(mime SHARED)
    target_compile_definitions(mime PRIVATE MIME__EXPORTS)
else()
    add_library(mime STATIC)
    target_compile_definitions(mime PRIVATE MIME__STATIC)
endif()

add_library(pfs::mime ALIAS mime)

if (NOT TARGET pfs::common)
    set(FETCHCONTENT_UPDATES_DISCONNECTED_COMMON ON)

    include(FetchContent)
    FetchContent_Declare(common
        GIT_REPOSITORY https://github.com/semenovf/common-lib.git
        GIT_TAG master
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/2ndparty/common
        SUBBUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/2ndparty/common)
    FetchContent_MakeAvailable(common)
endif()

target_sources(mime PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/src/mime.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/mime_enum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/read_mime.cpp)

target_include_directories(mime PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
target_link_libraries(mime PUBLIC pfs::common)
