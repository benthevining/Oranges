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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

include ("${ORANGES_ROOT_DIR}/scripts/OrangesMacros.cmake")

include (OrangesInstallPackages)

#

if(SYSTEM_PACKAGES)
	set (system_packages_flag SYSTEM_PACKAGES "${SYSTEM_PACKAGES}")
endif()

if(PIP_PACKAGES)
	set (pip_packages_flag PIP_PACKAGES "${PIP_PACKAGES}")
endif()

if(UPDATE_FIRST)
	set (update_flag UPDATE_FIRST)
endif()

if(OPTIONAL)
	set (optional_flag OPTIONAL)
endif()

oranges_install_packages (${system_packages_flag} ${pip_packages_flag} ${update_flag}
						  ${optional_flag})
