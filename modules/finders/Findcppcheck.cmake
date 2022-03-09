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

set_package_properties (cppcheck PROPERTIES URL "https://cppcheck.sourceforge.io/"
						DESCRIPTION "C++ code linter")

set (cppcheck_FOUND FALSE)

find_program (ORANGES_CPPCHECK NAMES cppcheck)

mark_as_advanced (FORCE ORANGES_CPPCHECK)

if(NOT ORANGES_CPPCHECK)
	if(cppcheck_FIND_REQUIRED)
		message (FATAL_ERROR "cppcheck program cannot be found!")
	endif()

	return ()
endif()

add_executable (cppcheck IMPORTED GLOBAL)

set_target_properties (cppcheck PROPERTIES IMPORTED_LOCATION "${ORANGES_CPPCHECK}")

add_executable (cppcheck::cppcheck ALIAS cppcheck)

set (cppcheck_FOUND TRUE)
