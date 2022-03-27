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

OrangesFindSystemPackageManager
-------------------------

This module finds an appropriate system package manager program, and provides functions to update and install packages.


Update all packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command::oranges_update_all_system_packages

	oranges_update_all_system_packages()

Updates all installed system packages.


Install new packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_install_system_packages

	oranges_install_system_packages (PACKAGES <packageNames...>
									 [UPDATE_FIRST] [OPTIONAL])

Cache variables:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- SYSTEM_PACKAGE_MANAGER_EXECUTABLE: this can be used to override the system package manager executable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("OrangesFindSystemPackageManager")

define_property (
	GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME BRIEF_DOCS "System package manager being used"
	FULL_DOCS "The name of the system package manager program being used")

if(SYSTEM_PACKAGE_MANAGER_EXECUTABLE)
	add_executable (system_pkg_manager IMPORTED GLOBAL)

	set_target_properties (system_pkg_manager PROPERTIES IMPORTED_LOCATION
														 "${SYSTEM_PACKAGE_MANAGER_EXECUTABLE}")

	add_executable (Oranges::system_pkg_manager ALIAS system_pkg_manager)

	set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME custom)

	message (DEBUG
			 "Using custom system package manager executable: ${SYSTEM_PACKAGE_MANAGER_EXECUTABLE}")
else()
	if(APPLE)
		find_package (Homebrew REQUIRED)
		set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME Homebrew)
	elseif(WIN32)
		find_package (Chocolatey REQUIRED)
		set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME Chocolatey)
	else()
		find_package (Apt REQUIRED)
		set_property (GLOBAL PROPERTY SYSTEM_PACKAGE_MANAGER_NAME apt)
	endif()
endif()

#

function(oranges_update_all_system_packages)
	oranges_add_function_message_context ()

	if(TARGET Oranges::system_pkg_manager)
		execute_process (COMMAND Oranges::system_pkg_manager ${SYSTEM_PACKAGE_MANAGER_UPDATE_FLAGS}
								 COMMAND_ECHO STDOUT)

		return ()
	endif()

	if(APPLE)
		homebrew_update_all ()
	elseif(WIN32)
		choclatey_update_all ()
	else()
		apt_update_all ()
	endif()
endfunction()

#

function(oranges_install_system_packages)

	oranges_add_function_message_context ()

	set (options UPDATE_FIRST OPTIONAL)
	set (multiValueArgs PACKAGES)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "${multiValueArgs}" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	oranges_forward_function_arguments (
		PREFIX
		ORANGES_ARG
		KIND
		option
		ARGS
		UPDATE_FIRST
		OPTIONAL)

	if(ORANGES_ARG_UPDATE_FIRST)
		oranges_update_all_system_packages ()
	endif()

	if(TARGET Oranges::system_pkg_manager)
		execute_process (
			COMMAND Oranges::system_pkg_manager ${SYSTEM_PACKAGE_MANAGER_INSTALL_FLAGS}
					${ORANGES_ARG_PACKAGES} COMMAND_ECHO STDOUT)

		return ()
	endif()

	if(APPLE)
		set (pkg_command homebrew_install_packages)
	elseif(WIN32)
		set (pkg_command chocolatey_install_packages)
	else()
		set (pkg_command apt_install_packages)
	endif()

	cmake_language (CALL "${pkg_command}" PACKAGES ${ORANGES_ARG_PACKAGES}
					${ORANGES_FORWARDED_ARGUMENTS})

endfunction()
