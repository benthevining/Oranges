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

set_package_properties (ksh PROPERTIES URL "" DESCRIPTION "UNIX shell")

oranges_file_scoped_message_context ("Findksh")

set (ksh_FOUND FALSE)

find_program (KSH_PROGRAM NAMES ksh pdksh)

mark_as_advanced (FORCE KSH_PROGRAM)

if(KSH_PROGRAM)
	add_executable (ksh_shell IMPORTED GLOBAL)

	set_target_properties (ksh_shell PROPERTIES IMPORTED_LOCATION "${KSH_PROGRAM}")

	oranges_set_shell_target_properties (TARGET ksh_shell NAME ksh STARTUP_SCRIPT "~/.profile")

	add_executable (ksh::ksh ALIAS ksh_shell)

	set (ksh_FOUND TRUE)
endif()
