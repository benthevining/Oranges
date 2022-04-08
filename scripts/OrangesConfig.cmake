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

set_and_check (ORANGES_ROOT_DIR "@PACKAGE_ORANGES_ROOT_DIR@")

#

include ("${CMAKE_CURRENT_LIST_DIR}/OrangesMacros.cmake")

list (APPEND CMAKE_MODULE_PATH "${ORANGES_CMAKE_MODULE_PATH}")

include ("${CMAKE_CURRENT_LIST_DIR}/OrangesTargets.cmake")

#

set (Oranges_FOUND TRUE)

include (FeatureSummary)
include (FindPackageMessage)

set_package_properties (Oranges PROPERTIES URL "https://github.com/benthevining/Oranges"
						DESCRIPTION "CMake modules and toolchains")

find_package_message (Oranges "Oranges package found -- installed on system"
					  "Oranges (system install)")

#

check_required_components ("@PROJECT_NAME@")
