# ======================================================================================
#    ____  _____            _   _  _____ ______  _____
#   / __ \|  __ \     /\   | \ | |/ ____|  ____|/ ____|
#  | |  | | |__) |   /  \  |  \| | |  __| |__  | (___
#  | |  | |  _  /   / /\ \ | . ` | | |_ |  __|  \___ \
#  | |__| | | \ \  / ____ \| |\  | |__| | |____ ____) |
#   \____/|_|  \_\/_/    \_\_| \_|\_____|______|_____/
#
#  This file is part of the Oranges open source CMake library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

function (_oranges_remove_directory dir_path)
    if (IS_DIRECTORY "${dir_path}")
        file (REMOVE_RECURSE "${dir_path}")
        message (STATUS "Removing cache directory: ${dir_path}")

        if (IS_DIRECTORY "${dir_path}")
            message (WARNING "Removing cache directory ${dir_path} failed!")
        endif ()
    endif ()
endfunction ()

#

# FETCHCONTENT_BASE_DIR
if (NOT "@FETCHCONTENT_BASE_DIR@" STREQUAL "")
    _oranges_remove_directory ("@FETCHCONTENT_BASE_DIR@")
endif ()

# ORANGES_FILE_DOWNLOAD_CACHE
if (NOT "@ORANGES_FILE_DOWNLOAD_CACHE@" STREQUAL "")
    _oranges_remove_directory ("@ORANGES_FILE_DOWNLOAD_CACHE@")
endif ()

_oranges_remove_directory ("@CMAKE_SOURCE_DIR@/Cache"
    )# @CMAKE_SOURCE_DIR@/Cache
_oranges_remove_directory ("@CMAKE_SOURCE_DIR@/.cache"
    )# @CMAKE_SOURCE_DIR@/.cache
_oranges_remove_directory ("@CMAKE_BINARY_DIR@/_deps"
    )# @CMAKE_BINARY_DIR@/_deps

if (DEFINED ENV{CPM_SOURCE_CACHE})
    _oranges_remove_directory ("$ENV{CPM_SOURCE_CACHE}")
endif ()
