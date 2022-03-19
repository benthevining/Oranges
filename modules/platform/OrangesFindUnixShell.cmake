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
- UnixShellName : name of the located shell
- UnixShellStartupScript : shell startup script filepath, if available
- UnixShellLogFile : shell logging file, directory, or file pattern, if available

Supported shells (in searching order):
- bash
- zsh
- fish
- ion
- pdksh
- tcsh
- Bourne shell (sh)

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

# bash

find_program (BASH_PROGRAM bash)

mark_as_advanced (FORCE BASH_PROGRAM)

if(BASH_PROGRAM)
	set (UnixShellName bash)
	set (UnixShellStartupScript "~/.bash_profile")

	add_executable (bash_shell IMPORTED GLOBAL)

	set_target_properties (bash_shell PROPERTIES IMPORTED_LOCATION "${BASH_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS bash_shell)

	set (UnixShellCommand Oranges::UnixShell ${BASH_FLAGS})

	return ()
endif()

# zsh

find_program (ZSH_PROGRAM zsh)

mark_as_advanced (FORCE ZSH_PROGRAM)

if(ZSH_PROGRAM)
	set (UnixShellName zsh)
	set (UnixShellStartupScript "~/.zshrc")

	add_executable (zsh_shell IMPORTED GLOBAL)

	set_target_properties (zsh_shell PROPERTIES IMPORTED_LOCATION "${ZSH_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS zsh_shell)

	set (UnixShellCommand Oranges::UnixShell ${ZSH_FLAGS})

	return ()
endif()

# fish

find_program (FISH_PROGRAM fish)

mark_as_advanced (FORCE FISH_PROGRAM)

if(FISH_PROGRAM)
	set (UnixShellName fish)
	set (UnixShellStartupScript "~/.config/fish/config.fish")
	set (UnixShellLogFile "~/.config/fish/fish_history*")

	add_executable (fish_shell IMPORTED GLOBAL)

	set_target_properties (fish_shell PROPERTIES IMPORTED_LOCATION "${FISH_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS fish_shell)

	set (UnixShellCommand Oranges::UnixShell ${FISH_FLAGS})

	return ()
endif()

# ion

find_program (ION_PROGRAM ion)

mark_as_advanced (FORCE ION_PROGRAM)

if(ION_PROGRAM)
	set (UnixShellName ion)
	set (UnixShellStartupScript "~/.config/ion/initrc")
	set (UnixShellLogFile "~/.local/share/ion/history")

	add_executable (ion_shell IMPORTED GLOBAL)

	set_target_properties (ion_shell PROPERTIES IMPORTED_LOCATION "${ION_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS ion_shell)

	set (UnixShellCommand Oranges::UnixShell ${ION_FLAGS})

	return ()
endif()

# pdksh

find_program (KSH_PROGRAM NAMES ksh sh pdksh)

mark_as_advanced (FORCE KSH_PROGRAM)

if(KSH_PROGRAM)
	set (UnixShellName ksh)
	set (UnixShellStartupScript "~/.profile")

	add_executable (ksh_shell IMPORTED GLOBAL)

	set_target_properties (ksh_shell PROPERTIES IMPORTED_LOCATION "${KSH_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS ksh_shell)

	set (UnixShellCommand Oranges::UnixShell ${KSH_FLAGS})

	return ()
endif()

# tcsh

find_program (TCSH_PROGRAM NAMES tcsh csh)

mark_as_advanced (FORCE TCSH_PROGRAM)

if(TCSH_PROGRAM)
	set (UnixShellName tcsh)
	set (UnixShellStartupScript "~/.cshrc")

	add_executable (tcsh_shell IMPORTED GLOBAL)

	set_target_properties (tcsh_shell PROPERTIES IMPORTED_LOCATION "${TCSH_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS tcsh_shell)

	set (UnixShellCommand Oranges::UnixShell ${TCSH_FLAGS})

	return ()
endif()

# sh

find_program (BOURNE_PROGRAM sh)

mark_as_advanced (FORCE BOURNE_PROGRAM)

if(BOURNE_PROGRAM)
	set (UnixShellName sh)
	set (UnixShellStartupScript "~/.profile")

	add_executable (sh_shell IMPORTED GLOBAL)

	set_target_properties (sh_shell PROPERTIES IMPORTED_LOCATION "${BOURNE_PROGRAM}")

	add_executable (Oranges::UnixShell ALIAS sh_shell)

	set (UnixShellCommand Oranges::UnixShell ${SH_FLAGS})

	return ()
endif()

message (FATAL_ERROR "No UNIX shell could be found!")
