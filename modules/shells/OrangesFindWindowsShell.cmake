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

Supported shells (in searching order):
- PowerShell
- CMD.EXE

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesShellTargetProperties)

# PowerShell

find_package (PowerShell)

if(TARGET PowerShell::PowerShell)
	add_executable (Oranges::WindowsShell ALIAS PowerShell::PowerShell)

	set (WindowsShellCommand Oranges::WindowsShell ${POWERSHELL_FLAGS})

	return ()
endif()

# CMD.EXE

find_package (cmd)

if(TARGET cmd::cmd)
	add_executable (Oranges::WindowsShell ALIAS cmd_exe)

	set (WindowsShellCommand Oranges::WindowsShell ${CMD_EXE_FLAGS})

	return ()
endif()

#

message (FATAL_ERROR "No Windows shell could be found!")
