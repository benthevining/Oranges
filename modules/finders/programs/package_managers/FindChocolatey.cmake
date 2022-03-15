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

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (Chocolatey PROPERTIES URL "https://chocolatey.org/"
						DESCRIPTION "Windows package manager")

set (Chocolatey_FOUND FALSE)

find_program (CHOCO choco)

if(NOT CHOCO)
	unset (CACHE{CHOCO})

	find_program (POWERSHELL powershell)

	if(Chocolatey_FIND_REQUIRED AND NOT POWERSHELL)
		message (
			FATAL_ERROR "Powershell is required for installing Chocolatey, and cannot be found!")
	endif()

	if(NOT Chocolatey_FIND_QUIETLY)
		message (STATUS "Installing Chocolatey...")
	endif()

	execute_process (COMMAND "${POWERSHELL}" Set-ExecutionPolicy Bypass COMMAND_ECHO STDOUT)

	execute_process (
		COMMAND
			"${POWERSHELL}" iex
			"((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
			COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

	find_program (CHOCO choco)

	if(Chocolatey_FIND_REQUIRED AND NOT CHOCO)
		message (FATAL_ERROR "Error installing Chocolatey!")
	endif()
endif()

mark_as_advanced (FORCE CHOCO POWERSHELL)

if(CHOCO)
	set (Chocolatey_FOUND TRUE)

	add_executable (Chocolatey IMPORTED GLOBAL)

	set_target_properties (Chocolatey PROPERTIES IMPORTED_LOCATION "${CHOCO}")

	add_executable (Chocolatey::Chocolatey ALIAS Chocolatey)
endif()

#

function(choclatey_update_all)

	if(NOT TARGET Chocolatey::Chocolatey)
		message (FATAL_ERROR "Chocolatey cannot be found!")
	endif()

	execute_process (COMMAND Chocolatey::Chocolatey update all COMMAND_ECHO STDOUT)

endfunction()

#

function(chocolatey_install_packages)

	if(NOT TARGET Chocolatey::Chocolatey)
		message (FATAL_ERROR "Chocolatey cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "PACKAGES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	if(ORANGES_ARG_UPDATE_FIRST)
		choclatey_update_all ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND Chocolatey::Chocolatey install ${ORANGES_ARG_PACKAGES} -y COMMAND_ECHO
							 STDOUT ${error_flag})

endfunction()
