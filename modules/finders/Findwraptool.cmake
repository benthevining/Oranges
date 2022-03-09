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

include (FeatureSummary)

set_package_properties (wraptool PROPERTIES URL "https://paceap.com/pro-audio/"
						DESCRIPTION "AAX plugin signing tool provided by PACE")

set (wraptool_FOUND FALSE)

find_program (WRAPTOOL_PROGRAM wraptool)

mark_as_advanced (FORCE WRAPTOOL_PROGRAM)

if(NOT WRAPTOOL_PROGRAM)
	if(wraptool_FIND_REQUIRED)
		message (FATAL_ERROR "wraptool program cannot be found!")
	endif()

	return ()
endif()

add_executable (wraptool IMPORTED GLOBAL)

set_target_properties (wraptool PROPERTIES IMPORTED_LOCATION "${WRAPTOOL_PROGRAM}")

add_executable (PACE::wraptool ALIAS wraptool)

set (wraptool_FOUND TRUE)
