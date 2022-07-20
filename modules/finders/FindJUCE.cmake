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

#[=======================================================================[.rst:

FindJUCE
-------------------------

A find module for the JUCE library.
This module attempts to locate a local copy of JUCE, and if this fails, fetches the JUCE sources from GitHub using CMake's ``FetchContent`` module.

Versions 6 and 7 are supported.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://juce.com/"
                        DESCRIPTION "Cross platform framework for plugin and app development")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

set (JUCE_ENABLE_MODULE_SOURCE_GROUPS ON)
set (JUCE_BUILD_EXAMPLES OFF)
set (JUCE_BUILD_EXTRAS OFF)

if (${CMAKE_FIND_PACKAGE_NAME}_VERSION)
    if ("${${CMAKE_FIND_PACKAGE_NAME}_VERSION}" VERSION_LESS 6.0.0)
        set (${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
             "JUCE versions older than 6 are not supported by this find module")
        return ()
    elseif ("${${CMAKE_FIND_PACKAGE_NAME}_VERSION}" VERSION_LESS 7.0.0)
        # the commit hash for the last JUCE 6 commit
        set (juce_git_tag 37d6161da2aa94d1530cef860b1642e1e4d9e08d)
    endif ()
endif ()

if (NOT DEFINED juce_git_tag)
    set (juce_git_tag origin/master)
endif ()

include (FetchContent)

FetchContent_Declare (JUCE GIT_REPOSITORY "https://github.com/juce-framework/JUCE.git"
                      GIT_TAG "${juce_git_tag}")

FetchContent_MakeAvailable (JUCE)

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "JUCE - found (downloaded)"
                      "JUCE [${juce_git_tag}]")
