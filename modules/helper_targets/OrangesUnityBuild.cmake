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

OrangesUnityBuild
-------------------------

Provides a helper target for configuring a target as a unity build.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesUnityBuild``

Provides flags for building a target as a unity build.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesUnityBuild)
    return ()
endif ()

add_library (OrangesUnityBuild INTERFACE)

# cmake-format: off
set_target_properties (OrangesUnityBuild PROPERTIES
                        UNITY_BUILD_MODE BATCH
                        UNITY_BUILD ON)
# cmake-format: on

install (TARGETS OrangesUnityBuild EXPORT OrangesTargets)

add_library (Oranges::OrangesUnityBuild ALIAS OrangesUnityBuild)
