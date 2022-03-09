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

set_package_properties (
	codesign PROPERTIES
	URL "https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Procedures/Procedures.html"
	DESCRIPTION "Apple's code signing tool")

set (codesign_FOUND FALSE)

find_program (CODESIGN_PROGRAM codesign)

mark_as_advanced (FORCE CODESIGN_PROGRAM)

if(NOT CODESIGN_PROGRAM)
	if(codesign_FIND_REQUIRED)
		message (FATAL_ERROR "codesign program cannot be found!")
	endif()

	return ()
endif()

add_executable (codesign IMPORTED GLOBAL)

set_target_properties (codesign PROPERTIES IMPORTED_LOCATION "${CODESIGN_PROGRAM}")

add_executable (Apple::codesign ALIAS codesign)

set (codesign_FOUND TRUE)
