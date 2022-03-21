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

A find module for the JUCE library. This module fetches the JUCE sources from GitHub.

Options:
- LEMONS_JUCE_BRANCH: the branch of the GitHub repository to use; develop or master. Defaults to develop.

Targets:
- all of JUCE's targets (the JUCE modules, etc)

Output variables:
- JUCE_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)
include (OrangesFetchRepository)

set_package_properties (JUCE PROPERTIES URL "https://juce.com/"
						DESCRIPTION "Cross platform framework for plugin and app development")

#

oranges_file_scoped_message_context ("FindJUCE")

#

set (LEMONS_JUCE_BRANCH "develop" CACHE STRING "The branch of the JUCE GitHub repository to use")
set_property (CACHE LEMONS_JUCE_BRANCH PROPERTY STRINGS "develop;master")
mark_as_advanced (FORCE LEMONS_JUCE_BRANCH)

if(JUCE_FIND_QUIETLY)
	set (quiet_flag QUIET)
endif()

oranges_fetch_repository (
	NAME
	JUCE
	GITHUB_REPOSITORY
	juce-framework/JUCE
	GIT_TAG
	"origin/${LEMONS_JUCE_BRANCH}"
	CMAKE_OPTIONS
	"JUCE_ENABLE_MODULE_SOURCE_GROUPS ON"
	"JUCE_BUILD_EXAMPLES OFF"
	"JUCE_BUILD_EXTRAS OFF"
	NEVER_LOCAL
	${quiet_flag})

unset (quiet_flag)

set (JUCE_FOUND TRUE)
