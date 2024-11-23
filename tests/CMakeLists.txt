################################################################################
# Copyright (c) 2023-2024 Vladislav Trifochkin
#
# This file is part of `mime-lib`.
#
################################################################################
project(mime-TESTS CXX C)

set(TEST_NAMES mime_by_extension)

foreach (name ${TEST_NAMES})
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE pfs::mime)
    add_test(NAME ${name} COMMAND ${name})
endforeach()
