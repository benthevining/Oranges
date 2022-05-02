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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

define_property (
    GLOBAL PROPERTY CACHE_DIR BRIEF_DOCS "Cache directory for downloaded dependencies"
    FULL_DOCS "Full path to the directory where downloaded dependencies will be stored")

define_property (
    GLOBAL PROPERTY CACHE_DISCONNECTED BRIEF_DOCS "All dependency fetching fully disconnected"
    FULL_DOCS "ON if all dependency fetching is fully disconnected")

if (ORANGES_PROPERTIES_LIST_FILE)
    file (APPEND "${ORANGES_PROPERTIES_LIST_FILE}" "CACHE_DIR GLOBAL\nCACHE_DISCONNECTED GLOBAL\n")
endif ()

oranges_file_scoped_message_context ("OrangesSetUpCache")

if (DEFINED ENV{CMAKE_CACHE})
    set (default_cache "$ENV{CMAKE_CACHE}")
else ()
    set (default_cache "${CMAKE_SOURCE_DIR}/Cache")
endif ()

set (FETCHCONTENT_BASE_DIR "${default_cache}"
     CACHE PATH "Directory in which to cache all downloaded git repos")

message (DEBUG "cache dir: ${FETCHCONTENT_BASE_DIR}")

unset (default_cache)

set_property (GLOBAL PROPERTY CACHE_DIR "${FETCHCONTENT_BASE_DIR}")

set (ORANGES_FILE_DOWNLOAD_CACHE "${FETCHCONTENT_BASE_DIR}"
     CACHE PATH "Directory in which to cache all downloaded files")

set (ExternalData_BINARY_ROOT "${FETCHCONTENT_BASE_DIR}"
     CACHE PATH "Directory in which to cache all downloaded data files")

mark_as_advanced (FORCE FETCHCONTENT_BASE_DIR ORANGES_FILE_DOWNLOAD_CACHE ExternalData_BINARY_ROOT)

if (NOT DEFINED ENV{CPM_SOURCE_CACHE})
    set (ENV{CPM_SOURCE_CACHE} "${FETCHCONTENT_BASE_DIR}")
endif ()

#

if (DEFINED ENV{CMAKE_CACHE_DISCONNECTED})
    if ($ENV{CMAKE_CACHE_DISCONNECTED})
        set (default_disconnect ON)
    else ()
        set (default_disconnect OFF)
    endif ()
else ()
    set (default_disconnect OFF)
endif ()

set (FETCHCONTENT_FULLY_DISCONNECTED "${default_disconnect}"
     CACHE BOOL "ON if all dependency fetching is fully disconnected")

unset (default_disconnect)

if (FETCHCONTENT_FULLY_DISCONNECTED)
    message (DEBUG "Oranges cache: disconnected for this run!")
endif ()

set_property (GLOBAL PROPERTY CACHE_DISCONNECTED "${FETCHCONTENT_FULLY_DISCONNECTED}")

set (ORANGES_FILE_DOWNLOAD_DISCONNECTED "${FETCHCONTENT_FULLY_DISCONNECTED}"
     CACHE BOOL "ON if all dependency fetching is fully disconnected")

mark_as_advanced (FORCE FETCHCONTENT_FULLY_DISCONNECTED ORANGES_FILE_DOWNLOAD_DISCONNECTED)
