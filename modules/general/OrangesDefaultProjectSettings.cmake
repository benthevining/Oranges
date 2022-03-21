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

This module sets up some project-specific defaults, and includes a basic set of modules used in most CMake projects.

Inclusion style: In each project

]]

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesDefaultCMakeSettings)
include (OrangesDocsBuildConfig)
include (OrangesDefaultInstallSettings)

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesWipeCacheTarget)
endif()

#

set (${PROJECT_NAME}_INCLUDED TRUE)

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

set (CPM_${PROJECT_NAME}_SOURCE "${PROJECT_SOURCE_DIR}" CACHE INTERNAL "")
set (FETCHCONTENT_SOURCE_DIR_${PROJECT_NAME} "${PROJECT_SOURCE_DIR}" CACHE INTERNAL "")

set (${PROJECT_NAME}_FOUND TRUE)

#

string (TOUPPER "${PROJECT_NAME}" _oranges_upper_project_name)

set (${_oranges_upper_project_name}_INSTALL_DEST "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
	 CACHE STRING "Directory below INSTALL_PREFIX where ${PROJECT_NAME} will be installed to")

mark_as_advanced (FORCE ${_oranges_upper_project_name}_INSTALL_DEST CPM_${PROJECT_NAME}_SOURCE
				  FETCHCONTENT_SOURCE_DIR_${PROJECT_NAME})

unset (_oranges_upper_project_name)
