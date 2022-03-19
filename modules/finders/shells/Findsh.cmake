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

set_package_properties (sh PROPERTIES URL "" DESCRIPTION "UNIX shell")

set (sh_FOUND FALSE)

find_program (SH_PROGRAM sh)

mark_as_advanced (FORCE SH_PROGRAM)

if(SH_PROGRAM)
	add_executable (sh_shell IMPORTED GLOBAL)

	set_target_properties (sh_shell PROPERTIES IMPORTED_LOCATION "${SH_PROGRAM}")

	oranges_set_shell_target_properties (TARGET sh_shell NAME sh STARTUP_SCRIPT "~/.profile")

	add_executable (sh::sh ALIAS sh_shell)

	set (sh_FOUND TRUE)
endif()
