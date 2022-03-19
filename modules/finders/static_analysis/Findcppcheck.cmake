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

A find module for the cppcheck static analysis tool.

Targets:
- cppcheck::cppcheck : The cppcheck executable.
- cppcheck::cppcheck-interface : Interface library that can be linked against to enable cppcheck integrations for a target

Output variables:
- cppcheck_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (cppcheck PROPERTIES URL "https://cppcheck.sourceforge.io/"
						DESCRIPTION "C++ code linter")

set (cppcheck_FOUND FALSE)

find_program (CPPCHECK NAMES cppcheck)

mark_as_advanced (FORCE CPPCHECK)

if(NOT CPPCHECK)
	if(cppcheck_FIND_REQUIRED)
		message (FATAL_ERROR "cppcheck program cannot be found!")
	endif()

	if(NOT cppcheck_FIND_QUIETLY)
		message (WARNING "cppcheck program cannot be found!")
	endif()

	return ()
endif()

if(NOT cppcheck_FIND_QUIETLY)
	message (VERBOSE "Using cppcheck!")
endif()

add_executable (cppcheck IMPORTED GLOBAL)

set_target_properties (cppcheck PROPERTIES IMPORTED_LOCATION "${CPPCHECK}")

add_executable (cppcheck::cppcheck ALIAS cppcheck)

set (cppcheck_FOUND TRUE)

set (CMAKE_CXX_CPPCHECK "${CPPCHECK};--suppress=preprocessorErrorDirective" CACHE STRING "")

mark_as_advanced (FORCE CMAKE_CXX_CPPCHECK)

set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

add_library (cppcheck-interface INTERFACE)

set_target_properties (cppcheck-interface PROPERTIES EXPORT_COMPILE_COMMANDS ON
													 CXX_CPPCHECK "${CMAKE_CXX_CPPCHECK}")

oranges_export_alias_target (cppcheck-interface cppcheck)
