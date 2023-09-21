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

if (NOT TARGET pfs::common)
    portable_target(INCLUDE_PROJECT
        ${PORTABLE_TARGET__CURRENT_PROJECT_DIR}/3rdparty/pfs/common/library.cmake)
endif()

portable_target(ADD_SHARED ${PROJECT_NAME} ALIAS pfs::mime EXPORTS MIME__EXPORTS)
portable_target(SOURCES ${PROJECT_NAME}
    ${CMAKE_CURRENT_LIST_DIR}/src/mime.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/mime_enum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/read_mime.cpp)
portable_target(INCLUDE_DIRS ${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
portable_target(LINK ${PROJECT_NAME} PUBLIC pfs::common)
