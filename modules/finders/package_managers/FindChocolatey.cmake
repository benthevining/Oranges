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

FindChocolatey
-------------------------

Find the Chocolatey package manager.

Options:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- CHOCO_NO_INSTALL : if set to OFF and Chocolatey cannot be found, then it will be installed at configure time.
If set to ON and Chocolatey cannot be found, then Chocolatey will not be installed and this module's functions will produce fatal errors.
Defaults to OFF.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Chocolatey_FOUND

Targets:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Chocolatey::Chocolatey : The Chocolatey executable.

Update installed packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: chocolatey_update_all

	chocolatey_update_all()

Updates all installed Chocolatey packages.


Install packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: chocolatey_install_packages

	chocolatey_install_packages (PACKAGES <packageNames>
								 [UPDATE_FIRST] [OPTIONAL])

Installs the list of packages using Chocolatey.
If the `UPDATE_FIRST` first option is present, all installed packages will be updated before installing new packages.
If the `OPTIONAL` option is present, it is not an error for a package to fail to install.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (Chocolatey PROPERTIES URL "https://chocolatey.org/"
						DESCRIPTION "Windows package manager")

#

oranges_file_scoped_message_context ("FindChocolatey")

#

option (CHOCO_NO_INSTALL "Don't attempt to install Chocolatey if it cannot be found" OFF)

set (Chocolatey_FOUND FALSE)

find_program (CHOCO choco)

if(NOT CHOCO AND NOT CHOCO_NO_INSTALL)
	unset (CACHE{CHOCO})

	include (OrangesFindWindowsShell)

	if(NOT Chocolatey_FIND_QUIETLY)
		message (STATUS "Installing Chocolatey...")
	endif()

	find_package_execute_process (COMMAND ${WindowsShellCommand} Set-ExecutionPolicy Bypass)

	find_package_execute_process (
		COMMAND ${WindowsShellCommand} iex
		"((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))")

	find_program (CHOCO choco)
endif()

mark_as_advanced (FORCE CHOCO POWERSHELL)

if(CHOCO)
	set (Chocolatey_FOUND TRUE)

	add_executable (Chocolatey IMPORTED GLOBAL)

	set_target_properties (Chocolatey PROPERTIES IMPORTED_LOCATION "${CHOCO}")

	add_executable (Chocolatey::Chocolatey ALIAS Chocolatey)
else()
	find_package_warning_or_error ("Chocolatey cannot be found!")
endif()

#

function(chocolatey_update_all)

	oranges_add_function_message_context ()

	if(NOT TARGET Chocolatey::Chocolatey)
		message (FATAL_ERROR "Chocolatey cannot be found!")
	endif()

	execute_process (COMMAND Chocolatey::Chocolatey update all COMMAND_ECHO STDOUT)

endfunction()

#

function(chocolatey_install_packages)

	oranges_add_function_message_context ()

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
