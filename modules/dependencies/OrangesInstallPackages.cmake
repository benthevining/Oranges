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
						  [RUBY_GEMS <gems...>]
						  [UPDATE_FIRST] [OPTIONAL])
```

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)
include (OrangesFindSystemPackageManager)

oranges_file_scoped_message_context ("OrangesInstallPackages")

find_package (Pip REQUIRED)
find_package (RubyGems)

find_package (asdf QUIET)

#

function(oranges_update_all_packages)
	oranges_add_function_message_context ()

	oranges_update_all_system_packages ()

	pip_upgrade_all ()

	if(TARGET Ruby::gem)
		ruby_update_all_gems ()
	endif()

	if(TARGET asdf::asdf)
		asdf_update ("${CMAKE_SOURCE_DIR}")
	endif()
endfunction()

#

function(oranges_install_packages)

	oranges_add_function_message_context ()

	set (options UPDATE_FIRST OPTIONAL)
	set (multiValueArgs SYSTEM_PACKAGES PIP_PACKAGES RUBY_GEMS)

	cmake_parse_arguments (ORANGES_ARG "${options}" "DIR" "${multiValueArgs}" ${ARGN})

	oranges_forward_function_arguments (
		PREFIX
		ORANGES_ARG
		KIND
		option
		ARGS
		UPDATE_FIRST
		OPTIONAL)

	if(ORANGES_ARG_SYSTEM_PACKAGES)
		oranges_install_system_packages (PACKAGES ${ORANGES_ARG_SYSTEM_PACKAGES}
										 ${ORANGES_FORWARDED_ARGUMENTS})
	endif()

	if(ORANGES_ARG_PIP_PACKAGES)
		pip_install_packages (PACKAGES ${ORANGES_ARG_PIP_PACKAGES} ${ORANGES_FORWARDED_ARGUMENTS})
	endif()

	if(ORANGES_ARG_RUBY_GEMS)
		if(TARGET Ruby::gem)
			ruby_install_gems (GEMS ${ORANGES_ARG_RUBY_GEMS} ${ORANGES_FORWARDED_ARGUMENTS})
		else()
			if(NOT ORANGES_ARG_OPTIONAL)
				message (FATAL_ERROR "Ruby gem not found!")
			endif()
		endif()
	endif()

	if(TARGET asdf::asdf)
		if(NOT ORANGES_ARG_DIR)
			set (ORANGES_ARG_DIR "${CMAKE_SOURCE_DIR}")
		endif()

		asdf_install ("${ORANGES_ARG_DIR}")
	endif()

endfunction()
