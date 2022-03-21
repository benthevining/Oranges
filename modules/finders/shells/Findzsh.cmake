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

set_package_properties (zsh PROPERTIES URL "" DESCRIPTION "UNIX shell")

oranges_file_scoped_message_context ("Findzsh")

set (zsh_FOUND FALSE)

find_program (ZSH_PROGRAM zsh)

mark_as_advanced (FORCE ZSH_PROGRAM)

if(ZSH_PROGRAM)
	add_executable (zsh_shell IMPORTED GLOBAL)

	set_target_properties (zsh_shell PROPERTIES IMPORTED_LOCATION "${ZSH_PROGRAM}")

	oranges_set_shell_target_properties (TARGET zsh_shell NAME zsh STARTUP_SCRIPT "~/.zshrc")

	add_executable (zsh::zsh ALIAS zsh_shell)

	set (zsh_FOUND TRUE)
endif()
