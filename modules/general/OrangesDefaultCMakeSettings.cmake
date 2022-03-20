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

This module sets some useful defaults for various CMake-wide settings.

Inclusion style: once globally

Targets:
- OrangesUnityBuild

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsDefaultPlatformSettings)
include (LemonsCmakeDevTools)
include (OrangesDefaultTarget)
include (CMakePackageConfigHelpers)
include (GNUInstallDirs)
include (OrangesDeprecateDirectoryScopedCommands)

#

set_property (GLOBAL PROPERTY REPORT_UNDEFINED_PROPERTIES
							  "${CMAKE_BINARY_DIR}/undefined_properties.log")

set_property (GLOBAL PROPERTY USE_FOLDERS YES)
set_property (GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "Targets")

#

set (CMAKE_SUPPRESS_REGENERATION TRUE)

set (CMAKE_INCLUDE_CURRENT_DIR ON)

set (CMAKE_INSTALL_MESSAGE LAZY)

set (CMAKE_EXPORT_PACKAGE_REGISTRY ON)

set (CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION ON)

set (CMAKE_CXX_VISIBILITY_PRESET hidden)
set (CMAKE_VISIBILITY_INLINES_HIDDEN YES)

set (CMAKE_DEBUG_POSTFIX -d)
set (CMAKE_RELWITHDEBINFO_POSTFIX -rd)
set (CMAKE_MINSIZEREL_POSTFIX -mr)

if(NOT APPLE)
	set (CMAKE_INSTALL_RPATH $ORIGIN)

	if(NOT WIN32)
		set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
		set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")
	endif()
endif()

if(IOS)
	set (CMAKE_OSX_DEPLOYMENT_TARGET 9.3)
else()
	set (CMAKE_OSX_DEPLOYMENT_TARGET 10.11)
endif()

set (CMAKE_COLOR_MAKEFILE ON)
set (CMAKE_VERBOSE_MAKEFILE ON)

#

add_library (OrangesUnityBuild INTERFACE)

set_target_properties (OrangesUnityBuild PROPERTIES UNITY_BUILD_MODE BATCH UNITY_BUILD ON)

oranges_export_alias_target (OrangesUnityBuild Oranges)

oranges_install_targets (TARGETS OrangesUnityBuild EXPORT OrangesTargets)

#

function(lemons_sort_target_sources target root_dir)

	if(NOT IS_DIRECTORY "${root_dir}")
		message (FATAL_ERROR "Source grouping root directory ${root_dir} does not exist!")
	endif()

	if(NOT TARGET "${target}")
		message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	get_target_property (target_sources "${target}" SOURCES)

	if(NOT target_sources)
		unset (target_sources)
	endif()

	get_target_property (target_interface_sources "${target}" INTERFACE_SOURCES)

	if(target_interface_sources)
		list (APPEND target_sources ${target_interface_sources})
	endif()

	if(NOT target_sources)
		message (WARNING "Error sorting sources for target ${target}")
		return ()
	endif()

	source_group (TREE "${root_dir}" FILES "${target_sources}")

endfunction()
