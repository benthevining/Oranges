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
include (LemonsCmakeDevTools)

set_package_properties (cpplint PROPERTIES URL "https://github.com/google/styleguide"
						DESCRIPTION "C++ code linter")

set (cpplint_FOUND FALSE)

find_program (CPPLINT NAMES cpplint)

mark_as_advanced (FORCE CPPLINT)

if(NOT CPPLINT)
	if(cpplint_FIND_REQUIRED)
		message (FATAL_ERROR "cpplint program cannot be found!")
	endif()

	return ()
endif()

if(NOT cpplint_FIND_QUIETLY)
	message (VERBOSE "Using cpplint!")
endif()

add_executable (cpplint IMPORTED GLOBAL)

set_target_properties (cpplint PROPERTIES IMPORTED_LOCATION "${CPPLINT}")

add_executable (Google::cpplint ALIAS cpplint)

set (cpplint_FOUND TRUE)

set (CMAKE_CXX_CPPLINT "${CPPLINT}" CACHE STRING "")
set (CMAKE_C_CPPLINT "${CPPLINT}" CACHE STRING "")

add_library (cpplint-interface INTERFACE)

set_target_properties (cpplint-interface PROPERTIES CXX_CPPLINT "${CPPLINT}" C_CPPLINT "${CPPLINT}")

oranges_export_alias_target (cpplint-interface Google)

oranges_install_targets (TARGETS cpplint-interface EXPORT OrangesTargets)
