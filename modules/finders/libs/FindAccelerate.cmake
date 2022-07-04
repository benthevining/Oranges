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

FindAccelerate
-------------------------

A find module for Apple's Accelerate framework.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Accelerate::Accelerate

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES
    URL "https://developer.apple.com/documentation/accelerate"
    DESCRIPTION "Apple's optimized high performance libraries")

add_library (Accelerate::Accelerate IMPORTED INTERFACE)

set_target_properties (Accelerate::Accelerate PROPERTIES INTERFACE_LINK_LIBRARIES
                                                         "-framework Accelerate")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Accelerate - found" "Accelerate")
