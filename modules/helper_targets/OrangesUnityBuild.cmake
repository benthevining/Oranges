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
- Oranges::OrangesUnityBuild

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

add_library (OrangesUnityBuild INTERFACE)

set_target_properties (OrangesUnityBuild PROPERTIES UNITY_BUILD_MODE BATCH UNITY_BUILD ON)

oranges_export_alias_target (OrangesUnityBuild Oranges)

oranges_install_targets (TARGETS OrangesUnityBuild EXPORT OrangesTargets)
