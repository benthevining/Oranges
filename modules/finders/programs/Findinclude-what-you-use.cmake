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

set_package_properties (include-what-you-use PROPERTIES URL "https://include-what-you-use.org/"
						DESCRIPTION "Static analysis for C++ includes")

set (include-what-you-use_FOUND FALSE)

find_program (INCLUDE_WHAT_YOU_USE NAMES include-what-you-use iwyu)

mark_as_advanced (FORCE INCLUDE_WHAT_YOU_USE)

if(NOT INCLUDE_WHAT_YOU_USE)
	if(include-what-you-use_FIND_REQUIRED)
		message (FATAL_ERROR "include-what-you-use program cannot be found!")
	endif()

	return ()
endif()

if(NOT include-what-you-use_FIND_QUIETLY)
	message (VERBOSE "Using include-what-you-use!")
endif()

add_executable (include-what-you-use IMPORTED GLOBAL)

set_target_properties (include-what-you-use PROPERTIES IMPORTED_LOCATION "${INCLUDE_WHAT_YOU_USE}")

add_executable (Google::include-what-you-use ALIAS include-what-you-use)

set (include-what-you-use_FOUND TRUE)

set (CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${INCLUDE_WHAT_YOU_USE}" CACHE STRING "")

add_library (include-what-you-use-interface INTERFACE)

set_target_properties (include-what-you-use-interface PROPERTIES CXX_INCLUDE_WHAT_YOU_USE
																 "${INCLUDE_WHAT_YOU_USE}")

oranges_export_alias_target (include-what-you-use-interface Google)

oranges_install_targets (TARGETS include-what-you-use-interface EXPORT OrangesTargets)
