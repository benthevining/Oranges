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

This module creates the target Oranges::OrangesCoverageFlags.

Inclusion style: once globally

Targets:
- Oranges::OrangesCoverageFlags

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

add_library (OrangesCoverageFlags INTERFACE)

target_compile_options (
	OrangesCoverageFlags INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:$<$<CONFIG:Debug>:-O0
								   -g --coverage>>)

target_link_options (OrangesCoverageFlags INTERFACE
					 $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:$<$<CONFIG:Debug>:--coverage>>)

oranges_export_alias_target (OrangesCoverageFlags Oranges)

oranges_install_targets (TARGETS OrangesCoverageFlags EXPORT OrangesTargets OPTIONAL)
