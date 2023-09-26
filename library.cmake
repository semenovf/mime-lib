################################################################################
# Copyright (c) 2023 Vladislav Trifochkin
#
# This file is part of `mime-lib`.
#
# Changelog:
#      2023.05.02 Initial version.
################################################################################
cmake_minimum_required (VERSION 3.11)
project(mime LANGUAGES C CXX)

option(MIME__BUILD_SHARED "Enable build shared library" OFF)
option(MIME__BUILD_STATIC "Enable build static library" ON)

if (NOT PORTABLE_TARGET__CURRENT_PROJECT_DIR)
    set(PORTABLE_TARGET__CURRENT_PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
endif()

if (MIME__BUILD_SHARED)
    portable_target(ADD_SHARED ${PROJECT_NAME} ALIAS pfs::mime EXPORTS MIME__EXPORTS)
endif()

if (MIME__BUILD_STATIC)
    set(STATIC_PROJECT_NAME ${PROJECT_NAME}-static)
    portable_target(ADD_STATIC ${STATIC_PROJECT_NAME} ALIAS pfs::mime::static EXPORTS MIME__STATIC)
endif()

if (NOT TARGET pfs::common)
    portable_target(INCLUDE_PROJECT
        ${PORTABLE_TARGET__CURRENT_PROJECT_DIR}/3rdparty/pfs/common/library.cmake)
endif()

set(_mime__sources
    ${CMAKE_CURRENT_LIST_DIR}/src/mime.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/mime_enum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/read_mime.cpp)

if (MIME__BUILD_SHARED)
    portable_target(SOURCES ${PROJECT_NAME} ${_mime__sources})
    portable_target(INCLUDE_DIRS ${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
    portable_target(LINK ${PROJECT_NAME} PUBLIC pfs::common)
endif()

if (MIME__BUILD_STATIC)
    portable_target(SOURCES ${STATIC_PROJECT_NAME} ${_mime__sources})
    portable_target(INCLUDE_DIRS ${STATIC_PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
    portable_target(LINK ${STATIC_PROJECT_NAME} PUBLIC pfs::common)
endif()
