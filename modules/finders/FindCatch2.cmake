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

FindCatch2
-------------------------

A find module for the Catch2 testing framework.

This module simply fetches the sources from GitHub using FetchContent.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FetchContent)
include (FeatureSummary)
include (FindPackageMessage)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://github.com/catchorg/Catch2"
    DESCRIPTION "C++ testing framework")

FetchContent_Declare (Catch2 GIT_REPOSITORY https://github.com/catchorg/Catch2.git
                      GIT_TAG origin/devel)

FetchContent_MakeAvailable (Catch2)

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Catch2 found (downloaded)" "Catch2 (GitHub)")
