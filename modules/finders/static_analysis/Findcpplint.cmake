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

#[[

A find module for the cpplint static analysis tool.

Targets:
- Google::cpplint : the cpplint executable
- Google::cpplint-interface : interface library that can be linked against to enable cpplint integrations for a target

Output variables:
- cpplint_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (cpplint PROPERTIES URL "https://github.com/google/styleguide"
						DESCRIPTION "C++ code linter")

oranges_file_scoped_message_context ("Findcpplint")

set (cpplint_FOUND FALSE)

find_program (CPPLINT NAMES cpplint)

mark_as_advanced (FORCE CPPLINT)

if(NOT CPPLINT)
	find_package_warning_or_error ("cpplint program cannot be found!")
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

mark_as_advanced (FORCE CMAKE_CXX_CPPLINT CMAKE_C_CPPLINT)

add_library (cpplint-interface INTERFACE)

set_target_properties (cpplint-interface PROPERTIES CXX_CPPLINT "${CMAKE_CXX_CPPLINT}"
													C_CPPLINT "${CMAKE_C_CPPLINT}")

oranges_export_alias_target (cpplint-interface Google)
