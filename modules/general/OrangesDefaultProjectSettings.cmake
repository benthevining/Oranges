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

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

#

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

# set (CPM_${PROJECT_NAME}_SOURCE "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "") set
# (${PROJECT_NAME} "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")
set (${PROJECT_NAME}_FOUND TRUE)

#

set (${PROJECT_NAME}_INSTALL_DEST "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
	 CACHE STRING "Directory below INSTALL_PREFIX where ${PROJECT_NAME} will be installed to")

mark_as_advanced (FORCE ${PROJECT_NAME}_INSTALL_DEST)
