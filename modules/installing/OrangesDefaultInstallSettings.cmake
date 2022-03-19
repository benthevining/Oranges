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

An aggregate helper module that includes OrangesInstallSystemLibs, OrangesDefaultCPackSettings, OrangesGeneratePkgConfig, and, if the including project is the top level project, also includes OrangesUninstallTarget.

If there is a target named `${PROJECT_NAME}` and the variable `${PROJECT_NAME}_SKIP_PKGCONFIG` is not set to a truthy value, then including this module will also call `oranges_create_pkgconfig_file (TARGET ${PROJECT_NAME})`.

Inclusion style: In each project

]]

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesInstallSystemLibs)
include (OrangesDefaultCPackSettings)
include (OrangesGeneratePkgConfig)

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesUninstallTarget)
endif()

if(NOT ${PROJECT_NAME}_SKIP_PKGCONFIG AND TARGET ${PROJECT_NAME})
	oranges_create_pkgconfig_file (TARGET ${PROJECT_NAME})
endif()
