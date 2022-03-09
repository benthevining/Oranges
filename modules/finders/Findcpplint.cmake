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

set_package_properties (cpplint PROPERTIES URL "https://github.com/google/styleguide"
						DESCRIPTION "C++ code linter")

set (cpplint_FOUND FALSE)

find_program (ORANGES_CPPLINT NAMES cpplint)

mark_as_advanced (FORCE ORANGES_CPPLINT)

if(NOT ORANGES_CPPLINT)
	if(cpplint_FIND_REQUIRED)
		message (FATAL_ERROR "cpplint program cannot be found!")
	endif()

	return ()
endif()

add_executable (cpplint IMPORTED GLOBAL)

set_target_properties (cpplint PROPERTIES IMPORTED_LOCATION "${ORANGES_CPPLINT}")

add_executable (Google::cpplint ALIAS cpplint)

set (cpplint_FOUND TRUE)
