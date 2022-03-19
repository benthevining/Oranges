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

set (FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/Cache"
	 CACHE PATH "Directory in which to cache all downloaded dependencies")

set (ORANGES_FILE_DOWNLOAD_CACHE "${FETCHCONTENT_BASE_DIR}"
	 CACHE PATH "Directory in which to cache all downloaded files")

mark_as_advanced (FORCE FETCHCONTENT_BASE_DIR ORANGES_FILE_DOWNLOAD_CACHE)

if(NOT DEFINED ENV{CPM_SOURCE_CACHE})
	set (ENV{CPM_SOURCE_CACHE} "${FETCHCONTENT_BASE_DIR}")
endif()
