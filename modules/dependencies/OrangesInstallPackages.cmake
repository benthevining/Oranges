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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

if(APPLE)
	find_package (Homebrew REQUIRED)
elseif(WIN32)
	find_package (Chocolatey REQUIRED)
else()
	find_package (Apt REQUIRED)
endif()

find_package (Pip REQUIRED)

#

function(oranges_update_all_packages)
	if(APPLE)
		homebrew_update_all ()
	elseif(WIN32)
		choclatey_update_all ()
	else()
		apt_update_all ()
	endif()

	pip_upgrade_all ()
endfunction()

#

function(oranges_install_packages)
	if(APPLE)
		homebrew_install_packages (${ARGN})
	elseif(WIN32)
		chocolatey_install_packages (${ARGN})
	else()
		apt_install_packages (${ARGN})
	endif()
endfunction()
