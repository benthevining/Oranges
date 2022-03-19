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

Attempts to locate a UNIX shell in approximate order of preference.

Targets:
- Oranges::UnixShell : the located shell executable

Output variables:
- UNIX_SHELL_COMMAND : a command line that includes any specified shell-specific flags that can be used as the COMMAND in add_custom_target, etc

Supported shells (in searching order):
- bash
- zsh
- fish
- ion
- pdksh (ksh)
- tcsh (csh)
- Bourne shell (sh)

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesShellTargetProperties)

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
