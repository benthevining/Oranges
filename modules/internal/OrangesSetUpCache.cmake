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

include (LemonsCmakeDevTools)

# if("${CMAKE_ROLE}" STREQUAL "PROJECT")
define_property (
	GLOBAL PROPERTY CACHE_DIR BRIEF_DOCS "Cache directory for downloaded dependencies"
	FULL_DOCS "Full path to the directory where downloaded dependencies will be stored")

oranges_file_scoped_message_context ("OrangesSetUpCache")
# endif()

if(DEFINED ENV{CMAKE_CACHE})
	set (default_cache "$ENV{CMAKE_CACHE}")
else()
	set (default_cache "${CMAKE_SOURCE_DIR}/Cache")
endif()

set (FETCHCONTENT_BASE_DIR "${default_cache}"
	 CACHE PATH "Directory in which to cache all downloaded git repos")

message (DEBUG "cache dir: ${FETCHCONTENT_BASE_DIR}")

unset (default_cache)

set_property (GLOBAL PROPERTY CACHE_DIR "${FETCHCONTENT_BASE_DIR}")

set (ORANGES_FILE_DOWNLOAD_CACHE "${FETCHCONTENT_BASE_DIR}"
	 CACHE PATH "Directory in which to cache all downloaded files")

mark_as_advanced (FORCE FETCHCONTENT_BASE_DIR ORANGES_FILE_DOWNLOAD_CACHE)

if(NOT DEFINED ENV{CPM_SOURCE_CACHE})
	set (ENV{CPM_SOURCE_CACHE} "${FETCHCONTENT_BASE_DIR}")
endif()
