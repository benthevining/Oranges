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

Cache variables:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- <upperProjectName>_INSTALL_DEST

#]=======================================================================]

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesDefaultCMakeSettings)
include (OrangesDocsBuildConfig)

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesWipeCacheTarget)
endif()

#

set (${PROJECT_NAME}_INCLUDED TRUE)

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

set (CPM_${PROJECT_NAME}_SOURCE "${PROJECT_SOURCE_DIR}" CACHE INTERNAL "")
set (FETCHCONTENT_SOURCE_DIR_${PROJECT_NAME} "${PROJECT_SOURCE_DIR}" CACHE INTERNAL "")

set (${PROJECT_NAME}_FOUND TRUE)

set (CMAKE_DISABLE_FIND_PACKAGE_${PROJECT_NAME} TRUE)

include (OrangesDefaultInstallSettings)
