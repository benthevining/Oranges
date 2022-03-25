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

OrangesFindUnixShell
-------------------------

Attempts to locate a UNIX shell executable, in approximate order of preference.

Supported shells (in searching order):
- bash
- zsh
- fish
- ion
- pdksh (ksh)
- tcsh (csh)
- Bourne shell (sh)

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- UNIX_SHELL_COMMAND : a command line that includes any specified shell-specific flags that can be used as the COMMAND in add_custom_target, etc

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::UnixShell : the located shell executable
- Unix::cp
- Unix::gzip
- Unix::mv
- Unix::rm
- Unix::tar


Global properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- UNIX_SHELL_NAME
- UNIX_SHELL_STARTUP_SCRIPT
- UNIX_SHELL_LOG_FILE
- UNIX_SHELL_FLAGS
- UNIX_SHELL_COMMAND


Execute a UNIX command
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: execute_unix_command

	execute_unix_command (COMMAND <BASH|CP|GZIP|MV|RM|TAR>
						  [ARGS <commandArgs...>]
						  [DIR <workingDirectory>]
						  [OPTIONAL])

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FindUnixCommands)
include (OrangesShellTargetProperties)
include (LemonsCmakeDevTools)

oranges_file_scoped_message_context ("OrangesFindUnixShell")

#

define_property (GLOBAL PROPERTY UNIX_SHELL_NAME BRIEF_DOCS "Name of the UNIX shell being used"
				 FULL_DOCS "Identifier of the UNIX shell executable being used")

define_property (
	GLOBAL PROPERTY UNIX_SHELL_STARTUP_SCRIPT
	BRIEF_DOCS "Startup script for the UNIX shell being used"
	FULL_DOCS "Full path to a startup script for the current UNIX shell, if one is available")

define_property (
	GLOBAL PROPERTY UNIX_SHELL_LOG_FILE BRIEF_DOCS "Log file for the UNIX shell being used"
	FULL_DOCS "Full path to a log file for the current UNIX shell, if one is available")

define_property (
	GLOBAL
	PROPERTY UNIX_SHELL_FLAGS
	BRIEF_DOCS "Shell-specific flags for the UNIX shell being used"
	FULL_DOCS
		"List of shell-specific flags to be used with the current UNIX shell executable, if any such flags have been set"
	)

define_property (
	GLOBAL
	PROPERTY UNIX_SHELL_COMMAND
	BRIEF_DOCS "UNIX shell command line"
	FULL_DOCS
		"A UNIX shell command line that includes any specified shell-specific flags and can be used as the COMMAND in add_custom_target, etc"
	)

#

# create imported targets for each found Unix command

if(CP)
	add_executable (unix_cp IMPORTED GLOBAL)

	set_target_properties (unix_cp PROPERTIES IMPORTED_LOCATION "${CP}")

	add_executable (Unix::cp ALIAS unix_cp)
endif()

if(GZIP)
	add_executable (unix_gzip IMPORTED GLOBAL)

	set_target_properties (unix_gzip PROPERTIES IMPORTED_LOCATION "${GZIP}")

	add_executable (Unix::gzip ALIAS unix_gzip)
endif()

if(MV)
	add_executable (unix_mv IMPORTED GLOBAL)

	set_target_properties (unix_mv PROPERTIES IMPORTED_LOCATION "${MV}")

	add_executable (Unix::mv ALIAS unix_mv)
endif()

if(RM)
	add_executable (unix_rm IMPORTED GLOBAL)

	set_target_properties (unix_rm PROPERTIES IMPORTED_LOCATION "${RM}")

	add_executable (Unix::rm ALIAS unix_rm)
endif()

if(TAR)
	add_executable (unix_tar IMPORTED GLOBAL)

	set_target_properties (unix_tar PROPERTIES IMPORTED_LOCATION "${TAR}")

	add_executable (Unix::tar ALIAS unix_tar)
endif()

#

function(execute_unix_command)

	oranges_add_function_message_context ()

	set (options OPTIONAL)
	set (oneValueArgs COMMAND DIR)
	set (multiValueArgs ARGS)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG COMMAND)

	if(ORANGES_ARG_ARGS)
		list (JOIN ${ORANGES_ARG_ARGS} " " command_args)
	endif()

	if(ORANGES_ARG_DIR)
		set (dir_flag WORKING_DIRECTORY "${ORANGES_ARG_DIR}")
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (fatal_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	if("${ORANGES_ARG_COMMAND}" STREQUAL "BASH")
		if(TARGET Bash::Bash)
			execute_process (COMMAND Bash::Bash ${command_args} ${dir_flag} ${fatal_flag}
									 COMMAND_ECHO STDOUT)
		else()
			if(NOT ORANGES_ARG_OPTIONAL)
				message (FATAL_ERROR "bash command not found!")
			endif()
		endif()

		return ()
	endif()

	if("${ORANGES_ARG_COMMAND}" STREQUAL "CP")
		set (target_name Unix::cp)
	elseif("${ORANGES_ARG_COMMAND}" STREQUAL "GZIP")
		set (target_name Unix::gzip)
	elseif("${ORANGES_ARG_COMMAND}" STREQUAL "MV")
		set (target_name Unix::mv)
	elseif("${ORANGES_ARG_COMMAND}" STREQUAL "RM")
		set (target_name Unix::rm)
	elseif("${ORANGES_ARG_COMMAND}" STREQUAL "TAR")
		set (target_name Unix::tar)
	else()
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with invalid COMMAND ${ORANGES_ARG_COMMAND}!")
	endif()

	if(NOT TARGET "${target_name}")
		if(ORANGES_ARG_OPTIONAL)
			return ()
		else()
			message (
				FATAL_ERROR
					"${CMAKE_CURRENT_FUNCTION} - ${ORANGES_ARG_COMMAND} executable was not found!")
		endif()
	endif()

	execute_process (COMMAND "${target_name}" ${command_args} ${dir_flag} ${fatal_flag}
							 COMMAND_ECHO STDOUT)

endfunction()

#

if(UNIX_SHELL_EXECUTABLE)
	add_executable (unix_shell IMPORTED GLOBAL)

	set_target_properties (unix_shell PROPERTIES IMPORTED_LOCATION "${UNIX_SHELL_EXECUTABLE}")

	add_executable (Oranges::UnixShell ALIAS unix_shell)

	set_property (GLOBAL PROPERTY UNIX_SHELL_COMMAND "${UNIX_SHELL_EXECUTABLE}")
	set_property (GLOBAL PROPERTY UNIX_SHELL_NAME custom)

	message (DEBUG "Using custom unix shell executable: ${UNIX_SHELL_EXECUTABLE}")

	return ()
endif()

#

function(_oranges_set_unix_shell_global_properties)

	if(NOT TARGET Oranges::UnixShell)
		return ()
	endif()

	get_target_property (shell_name Oranges::UnixShell SHELL_NAME)
	set_property (GLOBAL PROPERTY UNIX_SHELL_NAME "${shell_name}")

	get_target_property (startup_script Oranges::UnixShell SHELL_STARTUP_SCRIPT)
	if(startup_script)
		set_property (GLOBAL PROPERTY UNIX_SHELL_STARTUP_SCRIPT "${startup_script}")
	endif()

	get_target_property (log_file Oranges::UnixShell SHELL_LOG_FILE)
	if(log_file)
		set_property (GLOBAL PROPERTY UNIX_SHELL_LOG_FILE "${log_file}")
	endif()

	get_target_property (shell_flags Oranges::UnixShell SHELL_FLAGS)
	if(shell_flags)
		set_property (GLOBAL PROPERTY UNIX_SHELL_FLAGS "${shell_flags}")
	endif()

	set_property (GLOBAL PROPERTY UNIX_SHELL_COMMAND Oranges::UnixShell ${shell_flags})
	set (UNIX_SHELL_COMMAND Oranges::UnixShell ${shell_flags} PARENT_SCOPE)

endfunction()

cmake_language (DEFER CALL _oranges_set_unix_shell_global_properties)

#

# bash

find_package (Bash)

if(TARGET Bash::Bash)
	add_executable (Oranges::UnixShell ALIAS Bash::Bash)

	return ()
endif()

# zsh

find_package (zsh)

if(TARGET zsh::zsh)
	add_executable (Oranges::UnixShell ALIAS zsh::zsh)

	return ()
endif()

# fish

find_package (fish)

if(TARGET fish::fish)
	add_executable (Oranges::UnixShell ALIAS fish::fish)

	return ()
endif()

# ion

find_package (ion)

if(TARGET ion::ion)
	add_executable (Oranges::UnixShell ALIAS ion::ion)

	return ()
endif()

# ksh

find_package (ksh)

if(TARGET ksh::ksh)
	add_executable (Oranges::UnixShell ALIAS ksh::ksh)

	return ()
endif()

# csh

find_package (csh)

if(TARGET csh::csh)
	add_executable (Oranges::UnixShell ALIAS csh::csh)

	return ()
endif()

# sh

find_package (sh)

if(TARGET sh::sh)
	add_executable (Oranges::UnixShell ALIAS sh::sh)

	return ()
endif()

#

message (FATAL_ERROR "No UNIX shell could be found!")
