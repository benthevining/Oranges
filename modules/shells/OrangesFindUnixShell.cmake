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
- UnixShellCommand : a command line that includes any specified shell-specific flags that can be used as the COMMAND in add_custom_target, etc

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

# bash

find_package (Bash)

if(TARGET Bash::Bash)
	add_executable (Oranges::UnixShell ALIAS Bash::Bash)

	set (UnixShellCommand Oranges::UnixShell ${BASH_FLAGS})

	return ()
endif()

# zsh

find_package (zsh)

if(TARGET zsh::zsh)
	add_executable (Oranges::UnixShell ALIAS zsh::zsh)

	set (UnixShellCommand Oranges::UnixShell ${ZSH_FLAGS})

	return ()
endif()

# fish

find_package (fish)

if(TARGET fish::fish)
	add_executable (Oranges::UnixShell ALIAS fish::fish)

	set (UnixShellCommand Oranges::UnixShell ${FISH_FLAGS})

	return ()
endif()

# ion

find_package (ion)

if(TARGET ion::ion)
	add_executable (Oranges::UnixShell ALIAS ion::ion)

	set (UnixShellCommand Oranges::UnixShell ${ION_FLAGS})

	return ()
endif()

# ksh

find_package (ksh)

if(TARGET ksh::ksh)
	add_executable (Oranges::UnixShell ALIAS ksh::ksh)

	set (UnixShellCommand Oranges::UnixShell ${KSH_FLAGS})

	return ()
endif()

# csh

find_package (csh)

if(TARGET csh::csh)
	add_executable (Oranges::UnixShell ALIAS csh::csh)

	set (UnixShellCommand Oranges::UnixShell ${CSH_FLAGS})

	return ()
endif()

# sh

find_package (sh)

if(TARGET sh::sh)
	add_executable (Oranges::UnixShell ALIAS sh::sh)

	set (UnixShellCommand Oranges::UnixShell ${SH_FLAGS})

	return ()
endif()

#

message (FATAL_ERROR "No UNIX shell could be found!")
