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

include (LemonsCmakeDevTools)

define_property (TARGET INHERITED PROPERTY SHELL_NAME BRIEF_DOCS "Name of the shell being used"
				 FULL_DOCS "Identifier of the shell executable this target represents")

define_property (
	TARGET INHERITED PROPERTY SHELL_STARTUP_SCRIPT
	BRIEF_DOCS "Startup script for the shell being used"
	FULL_DOCS "Full path to a startup script for the current shell, if one is available")

define_property (
	TARGET INHERITED PROPERTY SHELL_LOG_FILE BRIEF_DOCS "Log file for the shell being used"
	FULL_DOCS "Full path to a log file for the current shell, if one is available")

define_property (
	TARGET INHERITED
	PROPERTY SHELL_FLAGS
	BRIEF_DOCS "Shell-specific flags for the shell being used"
	FULL_DOCS
		"List of shell-specific flags to be used with the current shell executable, if any such flags have been set"
	)

#

function(oranges_set_shell_target_properties)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET NAME STARTUP_SCRIPT LOG_FILE)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)

	if(NOT TARGET "${ORANGES_ARG_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${ORANGES_ARG_TARGET}!")
	endif()

	if(ORANGES_ARG_NAME)
		set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES SHELL_NAME "${ORANGES_ARG_NAME}")

		string (TOUPPER "${ORANGES_ARG_NAME}" NAME_UPPER)

		if(${NAME_UPPER}_FLAGS)
			set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES SHELL_FLAGS
																	  "${${NAME_UPPER}_FLAGS}")
		endif()
	endif()

	if(ORANGES_ARG_STARTUP_SCRIPT)
		set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES SHELL_STARTUP_SCRIPT
																  "${ORANGES_ARG_STARTUP_SCRIPT}")
	endif()

	if(ORANGES_ARG_LOG_FILE)
		set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES SHELL_LOG_FILE
																  "${ORANGES_ARG_LOG_FILE}")
	endif()

endfunction()
