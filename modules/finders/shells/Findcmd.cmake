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

set_package_properties (cmd PROPERTIES URL "" DESCRIPTION "Windows shell")

set (cmd_FOUND FALSE)

find_program (CMD_PROGRAM PowerShell)

mark_as_advanced (FORCE CMD_PROGRAM)

if(CMD_PROGRAM)
	add_executable (cmd_shell IMPORTED GLOBAL)

	set_target_properties (cmd_shell PROPERTIES IMPORTED_LOCATION "${CMD_PROGRAM}")

	oranges_set_shell_target_properties (TARGET cmd_shell NAME "CMD.EXE")

	add_executable (cmd::cmd ALIAS cmd_shell)

	set (cmd_FOUND TRUE)
endif()
