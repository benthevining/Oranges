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

OrangesDefaultProjectSettings
-------------------------

This module sets up some project-specific defaults, and includes a basic set of modules used in most CMake projects.

Inclusion style: In each project

#]=======================================================================]

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

set (CMAKE_CXX_VISIBILITY_PRESET hidden)
set (CMAKE_VISIBILITY_INLINES_HIDDEN YES)
set (CMAKE_SUPPRESS_REGENERATION TRUE)
set (CMAKE_INSTALL_MESSAGE LAZY)
set (CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION ON)
set (CMAKE_COLOR_MAKEFILE ON)
set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)
set (CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set (CMAKE_EXPORT_COMPILE_COMMANDS ON)

option (CMAKE_FIND_PACKAGE_PREFER_CONFIG
		"Prefer config files to find modules in find_package search" ON)

mark_as_advanced (FORCE CMAKE_FIND_PACKAGE_PREFER_CONFIG)

set_property (GLOBAL PROPERTY REPORT_UNDEFINED_PROPERTIES
							  "${CMAKE_BINARY_DIR}/undefined_properties.log")

set_property (GLOBAL PROPERTY USE_FOLDERS YES)
set_property (GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "Targets")

include (GNUInstallDirs)
include (CMakePackageConfigHelpers)
include (CPackComponent)
include (OrangesDefaultTarget)
include (OrangesDocsBuildConfig)
include (OrangesDeprecateDirectoryScopedCommands)

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesWipeCacheTarget)
endif()

#

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

set (CPM_${PROJECT_NAME}_SOURCE "${PROJECT_SOURCE_DIR}" CACHE INTERNAL "")
set (FETCHCONTENT_SOURCE_DIR_${PROJECT_NAME} "${PROJECT_SOURCE_DIR}" CACHE INTERNAL "")

set (${PROJECT_NAME}_FOUND TRUE)

set (CMAKE_DISABLE_FIND_PACKAGE_${PROJECT_NAME} TRUE)

include (OrangesDefaultInstallSettings)
