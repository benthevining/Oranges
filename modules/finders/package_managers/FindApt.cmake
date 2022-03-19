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

Find module for the apt package manager.

This module first tries to find apt-get, then falls back to apt if apt-get cannot be found.

Note that sudo is used on Linux.

Output variables:
- Apt_FOUND

## Functions:

### apt_update_all
```
apt_update_all()
```

Updates all installed packages.


### apt_install_packages
```
apt_install_packages (PACKAGES <packageNames>
					  [UPDATE_FIRST] [OPTIONAL])
```

Installs the list of packages using apt.
If the `UPDATE_FIRST` first option is present, all installed packages will be updated before installing new packages.
If the `OPTIONAL` option is present, it is not an error for a package to fail to install.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

define_property (
	GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME BRIEF_DOCS "System package manager being used"
	FULL_DOCS "The name of the system package manager program being used")

set_package_properties (Apt PROPERTIES URL "https://linux.die.net/man/8/apt-get"
						DESCRIPTION "Linux package manager")

set (Apt_FOUND FALSE)

find_program (SUDO sudo)

if(Apt_FIND_REQUIRED AND NOT SUDO)
	message (FATAL_ERROR "sudo is required on Linux!")
endif()

# use apt-get if available, else apt or dnf TO DO: yum

find_program (APT_GET apt-get)

if(APT_GET)
	set (apt_program "${APT_GET}" CACHE INTERNAL "")
	set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME apt-get)
else()
	find_program (APT apt)

	if(APT)
		set (apt_program "${APT}" CACHE INTERNAL "")
		set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME apt)
	else()
		find_program (DNF dnf)

		if(DNF)
			set (apt_program "${DNF}" CACHE INTERNAL "")
			set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME dnf)
		else()
			find_package_warning_or_error ("No package manager program can be found!")
		endif()
	endif()
endif()

mark_as_advanced (FORCE APT_GET APT DNF)

if(apt_program)
	set (Apt_FOUND TRUE)
endif()

#

function(apt_update_all)

	if(NOT apt_program)
		message (FATAL_ERROR "Apt cannot be found!")
	endif()

	execute_process (COMMAND "${SUDO}" "${apt_program}" update COMMAND_ECHO STDOUT)

	execute_process (COMMAND "${SUDO}" "${apt_program}" COMMAND_ECHO STDOUT)

endfunction()

#

function(apt_install_packages)

	if(NOT apt_program)
		message (FATAL_ERROR "Apt cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "PACKAGES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	if(ORANGES_ARG_UPDATE_FIRST)
		apt_update_all ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND "${SUDO}" "${apt_program}" install -y --no-install-recommends
							 ${ORANGES_ARG_PACKAGES} COMMAND_ECHO STDOUT ${error_flag})

endfunction()
