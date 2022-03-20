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

# generated find module for package @ORANGES_ARG_NAME@

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

set (source_dir "@@ORANGES_ARG_NAME@_SOURCE_DIR@")

set (@ORANGES_ARG_NAME@_SOURCE_DIR "${source_dir}")
set (FETCHCONTENT_SOURCE_DIR_@ORANGES_ARG_NAME@ "${source_dir}")

if(NOT @ORANGES_ARG_NAME@_INCLUDED)
	add_subdirectory ("${source_dir}" "${CMAKE_CURRENT_BINARY_DIR}/@ORANGES_ARG_NAME@")
	set (@ORANGES_ARG_NAME@_INCLUDED TRUE)
endif()

set (@ORANGES_ARG_NAME@_FOUND TRUE)

unset (source_dir)
