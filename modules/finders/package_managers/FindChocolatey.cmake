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

Find module for the Chocolatey package manager.

Options:
- CHOCO_NO_INSTALL : if set to OFF and Chocolatey cannot be found, then it will be installed at configure time.
If set to ON and Chocolatey cannot be found, then Chocolatey will not be installed and this module's functions will produce fatal errors.
Defaults to OFF.

Targets:
- Chocolatey::Chocolatey : The Chocolatey executable.

Output variables:
- Chocolatey_FOUND

## Functions:

### choclatey_update_all
```
choclatey_update_all()
```

Updates all installed packages.


### chocolatey_install_packages
```
chocolatey_install_packages (PACKAGES <packageNames>
						     [UPDATE_FIRST] [OPTIONAL])
```

Installs the list of packages using Chocolatey.
If the `UPDATE_FIRST` first option is present, all installed packages will be updated before installing new packages.
If the `OPTIONAL` option is present, it is not an error for a package to fail to install.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (Chocolatey PROPERTIES URL "https://chocolatey.org/"
						DESCRIPTION "Windows package manager")

option (CHOCO_NO_INSTALL "Don't attempt to install Chocolatey if it cannot be found" OFF)

set (Chocolatey_FOUND FALSE)

find_program (CHOCO choco)

if(NOT CHOCO AND NOT CHOCO_NO_INSTALL)
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
