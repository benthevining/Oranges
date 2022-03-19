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

Attempts to locate a Windows shell in approximate order of preference.

Targets:
- Oranges::WindowsShell : the located shell executable

Output variables:
- WindowsShellCommand : a command line that includes any specified shell-specific flags that can be used as the COMMAND in add_custom_target, etc
- WindowsShellName : name of the located shell
- WindowsShellStartupScript : shell startup script filepath, if available
- WindowsShellLogFile : shell logging file, directory, or file pattern, if available

Supported shells (in searching order):
- PowerShell
- CMD.EXE
- Hamilton C shell

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

# PowerShell

find_program (POWERSHELL_PROGRAM PowerShell)

mark_as_advanced (FORCE POWERSHELL_PROGRAM)

if(POWERSHELL_PROGRAM)
	set (WindowsShellName PowerShell)
	set (WindowsShellStartupScript
		 "%USERPROFILE%\\Documents \\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1")

	add_executable (powershell IMPORTED GLOBAL)

	set_target_properties (powershell PROPERTIES IMPORTED_LOCATION "${POWERSHELL_PROGRAM}")

	add_executable (Oranges::WindowsShell ALIAS powershell)

	set (WindowsShellCommand Oranges::WindowsShell ${POWERSHELL_FLAGS})

	return ()
endif()

# CMD.EXE

find_program (CMD_EXE_PROGRAM CMD)

mark_as_advanced (FORCE CMD_EXE_PROGRAM)

if(CMD_EXE_PROGRAM)
	set (WindowsShellName CMD.EXE)

	add_executable (cmd_exe IMPORTED GLOBAL)

	set_target_properties (cmd_exe PROPERTIES IMPORTED_LOCATION "${CMD_EXE_PROGRAM}")

	add_executable (Oranges::WindowsShell ALIAS cmd_exe)

	set (WindowsShellCommand Oranges::WindowsShell ${CMD_EXE_FLAGS})

	return ()
endif()

# Hamilton C shell

find_program (CSH_PROGRAM csh)

mark_as_advanced (FORCE CSH_PROGRAM)

if(CSH_PROGRAM)
	set (WindowsShellName csh)
	set (WindowsShellStartupScript startup.csh)

	add_executable (csh_shell IMPORTED GLOBAL)

	set_target_properties (csh_shell PROPERTIES IMPORTED_LOCATION "${CSH_PROGRAM}")

	add_executable (Oranges::WindowsShell ALIAS csh_shell)

	set (WindowsShellCommand Oranges::WindowsShell ${CSH_FLAGS})

	return ()
endif()

message (FATAL_ERROR "No Windows shell could be found!")
