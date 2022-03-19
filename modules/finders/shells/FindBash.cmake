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

include (OrangesFindPackageHelpers)
include (OrangesShellTargetProperties)

set_package_properties (Bash PROPERTIES URL "" DESCRIPTION "UNIX shell")

set (Bash_FOUND FALSE)

find_program (BASH_PROGRAM bash)

mark_as_advanced (FORCE BASH_PROGRAM)

if(BASH_PROGRAM)
	add_executable (bash_shell IMPORTED GLOBAL)

	set_target_properties (bash_shell PROPERTIES IMPORTED_LOCATION "${BASH_PROGRAM}")

	oranges_set_shell_target_properties (TARGET bash_shell NAME bash STARTUP_SCRIPT
										 "~/.bash_profile")

	add_executable (Bash::Bash ALIAS bash_shell)

	set (Bash_FOUND TRUE)
endif()
