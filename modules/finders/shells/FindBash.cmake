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

FindBash
-------------------------

Find the Bash shell.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Bash_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Bash::Bash : the Bash executable

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FindUnixCommands)
include (OrangesFindPackageHelpers)
include (OrangesShellTargetProperties)

set_package_properties (Bash PROPERTIES URL "" DESCRIPTION "UNIX shell")

oranges_file_scoped_message_context ("FindBash")

set (Bash_FOUND FALSE)

if(BASH)
	add_executable (bash_shell IMPORTED GLOBAL)

	set_target_properties (bash_shell PROPERTIES IMPORTED_LOCATION "${BASH}")

	oranges_set_shell_target_properties (TARGET bash_shell NAME bash STARTUP_SCRIPT
										 "~/.bash_profile")

	add_executable (Bash::Bash ALIAS bash_shell)

	set (Bash_FOUND TRUE)
endif()
