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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

@PACKAGE_INIT@

include (CMakeFindDependencyMacro)

# find_dependency ()

set (ORANGES_ROOT_DIR "@PACKAGE_ORANGES_ROOT_DIR@")

include ("${CMAKE_CURRENT_LIST_DIR}/OrangesMacros.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/OrangesTargets.cmake")

#

check_required_components ("@PROJECT_NAME@")
