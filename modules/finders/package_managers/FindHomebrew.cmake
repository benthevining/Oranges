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

Find module for the Homebrew package manager.

Options:
- HOMEBREW_NO_INSTALL : if set to OFF and Homebrew cannot be found, then it will be installed at configure time.
If set to ON and Homebrew cannot be found, then Homebrew will not be installed and this module's functions will produce fatal errors.
Defaults to OFF.

Targets:
- Homebrew::Homebrew : the Homebrew executable

Output variables:
- Homebrew_FOUND

## Functions:

### homebrew_update_all
```
homebrew_update_all()
```

Updates all installed packages.


### homebrew_install_packages
```
homebrew_install_packages (PACKAGES <packageNames>
						   [UPDATE_FIRST] [OPTIONAL])
```

Installs the list of packages using Homebrew.
If the `UPDATE_FIRST` first option is present, all installed packages will be updated before installing new packages.
If the `OPTIONAL` option is present, it is not an error for a package to fail to install.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)
include (OrangesDownloadFile)

set_package_properties (Homebrew PROPERTIES URL "https://brew.sh/"
						DESCRIPTION "MacOS package manager")

set (Homebrew_FOUND FALSE)

option (HOMEBREW_NO_INSTALL "Don't attempt to install Homebrew if it cannot be found" OFF)

mark_as_advanced (FORCE HOMEBREW_NO_INSTALL)

find_program (HOMEBREW brew)

if(NOT HOMEBREW AND NOT HOMEBREW_NO_INSTALL)
	unset (CACHE{HOMEBREW})

	include (OrangesFindUnixShell)

	if(Homebrew_FIND_QUIETLY)
		set (quiet_flag QUIET)
	else()
		message (STATUS "Installing Homebrew...")
	endif()

	oranges_download_file (
		URL
		"https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
		FILENAME
		install_homebrew.sh
		PATH_OUTPUT
		install_script
		${quiet_flag})

	unset (quiet_flag)

	find_package_execute_process (COMMAND ${UnixShellCommand} "${install_script}")

	unset (install_script)

	find_program (HOMEBREW brew)
endif()

mark_as_advanced (FORCE HOMEBREW BASH)

if(HOMEBREW)
	set (Homebrew_FOUND TRUE)

	add_executable (Homebrew IMPORTED GLOBAL)

	set_target_properties (Homebrew PROPERTIES IMPORTED_LOCATION "${HOMEBREW}")

	add_executable (Homebrew::Homebrew ALIAS Homebrew)
else()
	find_package_warning_or_error ("Homebrew cannot be found!")
endif()

#

function(homebrew_update_all)

	if(NOT TARGET Homebrew::Homebrew)
		message (FATAL_ERROR "Homebrew cannot be found!")
	endif()

	execute_process (COMMAND Homebrew::Homebrew update COMMAND_ECHO STDOUT)

	execute_process (COMMAND Homebrew::Homebrew upgrade COMMAND_ECHO STDOUT)

endfunction()

#

function(homebrew_install_packages)

	if(NOT TARGET Homebrew::Homebrew)
		message (FATAL_ERROR "Homebrew cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "PACKAGES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	if(ORANGES_ARG_UPDATE_FIRST)
		homebrew_update_all ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND Homebrew::Homebrew install ${ORANGES_ARG_PACKAGES} COMMAND_ECHO STDOUT
							 ${error_flag})

endfunction()