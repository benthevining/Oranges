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

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesInstallSystemLibs)
include (OrangesDefaultCPackSettings)

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesUninstallTarget)
endif()

include (OrangesGeneratePkgConfig)

if(NOT ${PROJECT_NAME}_SKIP_PKGCONFIG AND TARGET ${PROJECT_NAME})
	oranges_create_pkgconfig_file (TARGET ${PROJECT_NAME})
endif()
