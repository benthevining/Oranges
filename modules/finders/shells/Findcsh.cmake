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

set_package_properties (csh PROPERTIES URL "" DESCRIPTION "UNIX shell")

set (csh_FOUND FALSE)

find_program (CSH_PROGRAM NAMES tcsh csh)

mark_as_advanced (FORCE CSH_PROGRAM)

if(CSH_PROGRAM)
	add_executable (csh_shell IMPORTED GLOBAL)

	set_target_properties (csh_shell PROPERTIES IMPORTED_LOCATION "${CSH_PROGRAM}")

	oranges_set_shell_target_properties (TARGET csh_shell NAME csh STARTUP_SCRIPT "~/.cshrc")

	add_executable (csh::csh ALIAS csh_shell)

	set (csh_FOUND TRUE)
endif()
