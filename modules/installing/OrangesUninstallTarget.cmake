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

OrangesUninstallTarget
-------------------------

When this module is included, it creates a target that uninstalls all of the project's installed files.

Inclusion style: Once globally, preferably from top-level project


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- uninstall

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("OrangesUninstallTarget")

if(TARGET uninstall)
	message (AUTHOR_WARNING "uninstall target already exists!")
	return ()
endif()

if(PROJECT_IS_TOP_LEVEL)
	message (DEBUG "Oranges - adding uninstall target in project ${PROJECT_NAME}")
else()
	message (AUTHOR_WARNING "Creating uninstall target in non-top-level project ${PROJECT_NAME}!")
endif()

set (configured_script "${CMAKE_BINARY_DIR}/uninstall.cmake")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/uninstall.cmake" "${configured_script}" @ONLY)

add_custom_target (
	uninstall
	COMMAND "${CMAKE_COMMAND} -P ${configured_script}"
	COMMENT "Running uninstall..."
	WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
	VERBATIM USES_TERMINAL)

set_target_properties (uninstall PROPERTIES
	FOLDER Utility
	LABELS Utility
	XCODE_GENERATE_SCHEME OFF
	EchoString "Uninstalling...")

unset (configured_script)
