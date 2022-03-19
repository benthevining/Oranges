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

This module provides functions that wrap platform-specific package managers, as well as Python's pip.

Inclusion style: once globally

## Functions:

### oranges_update_all_packages
```
oranges_update_all_packages()
```

Updates all installed system packages.


### oranges_install_packages
```
oranges_install_packages ([SYSTEM_PACKAGES <packageNames...>]
						  [PIP_PACKAGES <packageNames...>]
						  [UPDATE_FIRST] [OPTIONAL])
```

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)

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

	set (options UPDATE_FIRST OPTIONAL)
	set (multiValueArgs SYSTEM_PACKAGES PIP_PACKAGES)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "${multiValueArgs}" ${ARGN})

	oranges_forward_function_arguments (
		PREFIX
		ORANGES_ARG
		KIND
		option
		ARGS
		UPDATE_FIRST
		OPTIONAL)

	if(ORANGES_ARG_SYSTEM_PACKAGES)
		if(APPLE)
			set (pkg_command homebrew_install_packages)
		elseif(WIN32)
			set (pkg_command chocolatey_install_packages)
		else()
			set (pkg_command apt_install_packages)
		endif()

		cmake_language (CALL "${pkg_command}" PACKAGES ${ORANGES_ARG_SYSTEM_PACKAGES}
						${ORANGES_FORWARDED_ARGUMENTS})
	endif()

	if(ORANGES_ARG_PIP_PACKAGES)
		pip_install_packages (PACKAGES ${ORANGES_ARG_PIP_PACKAGES} ${ORANGES_FORWARDED_ARGUMENTS})
	endif()

endfunction()