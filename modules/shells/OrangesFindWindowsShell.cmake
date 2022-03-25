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

OrangesFindWindowsShell
-------------------------

Attempts to locate a Windows shell executable, in approximate order of preference.

Supported shells (in searching order):
- PowerShell
- CMD.EXE

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- WINDOWS_SHELL_COMMAND : a command line that includes any specified shell-specific flags that can be used as the COMMAND in add_custom_target, etc

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::WindowsShell : the located shell executable


Global properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- WINDOWS_SHELL_NAME
- WINDOWS_SHELL_STARTUP_SCRIPT
- WINDOWS_SHELL_LOG_FILE
- WINDOWS_SHELL_FLAGS
- WINDOWS_SHELL_COMMAND

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesShellTargetProperties)
include (LemonsCmakeDevTools)

oranges_file_scoped_message_context ("OrangesFindWindowsShell")

#

define_property (
	GLOBAL PROPERTY WINDOWS_SHELL_NAME BRIEF_DOCS "Name of the Windows shell being used"
	FULL_DOCS "Identifier of the Windows shell executable being used")

define_property (
	GLOBAL PROPERTY WINDOWS_SHELL_STARTUP_SCRIPT
	BRIEF_DOCS "Startup script for the Windows shell being used"
	FULL_DOCS "Full path to a startup script for the current Windows shell, if one is available")

define_property (
	GLOBAL PROPERTY WINDOWS_SHELL_LOG_FILE BRIEF_DOCS "Log file for the Windows shell being used"
	FULL_DOCS "Full path to a log file for the current Windows shell, if one is available")

define_property (
	GLOBAL
	PROPERTY WINDOWS_SHELL_FLAGS
	BRIEF_DOCS "Shell-specific flags for the Windows shell being used"
	FULL_DOCS
		"List of shell-specific flags to be used with the current Windows shell executable, if any such flags have been set"
	)

define_property (
	GLOBAL
	PROPERTY WINDOWS_SHELL_COMMAND
	BRIEF_DOCS "Windows shell command line"
	FULL_DOCS
		"A Windows shell command line that includes any specified shell-specific flags and can be used as the COMMAND in add_custom_target, etc"
	)

#

if(WINDOWS_SHELL_EXECUTABLE)
	add_executable (windows_shell IMPORTED GLOBAL)

	set_target_properties (windows_shell PROPERTIES IMPORTED_LOCATION "${WINDOWS_SHELL_EXECUTABLE}")

	add_executable (Oranges::WindowsShell ALIAS windows_shell)

	set_property (GLOBAL PROPERTY WINDOWS_SHELL_COMMAND "${WINDOWS_SHELL_EXECUTABLE}")
	set_property (GLOBAL PROPERTY WINDOWS_SHELL_NAME custom)

	message (DEBUG "Using custom windows shell executable: ${WINDOWS_SHELL_EXECUTABLE}")

	return ()
endif()

#

function(_oranges_set_windows_shell_global_properties)

	if(NOT TARGET Oranges::WindowsShell)
		return ()
	endif()

	get_target_property (shell_name Oranges::WindowsShell SHELL_NAME)
	set_property (GLOBAL PROPERTY WINDOWS_SHELL_NAME "${shell_name}")

	get_target_property (startup_script Oranges::WindowsShell SHELL_STARTUP_SCRIPT)
	if(startup_script)
		set_property (GLOBAL PROPERTY WINDOWS_SHELL_STARTUP_SCRIPT "${startup_script}")
	endif()

	get_target_property (log_file Oranges::WindowsShell SHELL_LOG_FILE)
	if(log_file)
		set_property (GLOBAL PROPERTY WINDOWS_SHELL_LOG_FILE "${log_file}")
	endif()

	get_target_property (shell_flags Oranges::WindowsShell SHELL_FLAGS)
	if(shell_flags)
		set_property (GLOBAL PROPERTY WINDOWS_SHELL_FLAGS "${shell_flags}")
	endif()

	set_property (GLOBAL PROPERTY WINDOWS_SHELL_COMMAND Oranges::WindowsShell ${shell_flags})
	set (WINDOWS_SHELL_COMMAND Oranges::WindowsShell ${shell_flags} PARENT_SCOPE)

endfunction()

cmake_language (DEFER CALL _oranges_set_windows_shell_global_properties)

#

# PowerShell

find_package (PowerShell)

if(TARGET PowerShell::PowerShell)
	add_executable (Oranges::WindowsShell ALIAS PowerShell::PowerShell)

	return ()
endif()

# CMD.EXE

find_package (cmd)

if(TARGET cmd::cmd)
	add_executable (Oranges::WindowsShell ALIAS cmd_exe)

	return ()
endif()

#

message (FATAL_ERROR "No Windows shell could be found!")
