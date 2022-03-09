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
	xcodebuild PROPERTIES
	URL "https://developer.apple.com/library/archive/technotes/tn2339/_index.html"
	DESCRIPTION "Command-line build tool for XCode")

set (xcodebuild_FOUND FALSE)

find_program (XCODE_BUILD xcodebuild)

mark_as_advanced (FORCE XCODE_BUILD)

if(NOT XCODE_BUILD)
	if(xcodebuild_FIND_REQUIRED)
		message (FATAL_ERROR "xcodebuild program cannot be found!")
	endif()

	return ()
endif()

add_executable (xcodebuild IMPORTED GLOBAL)

set_target_properties (xcodebuild PROPERTIES IMPORTED_LOCATION "${XCODE_BUILD}")

add_executable (Apple::xcodebuild ALIAS xcodebuild)

set (xcodebuild_FOUND TRUE)
