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

set_package_properties (fish PROPERTIES URL "" DESCRIPTION "UNIX shell")

set (fish_FOUND FALSE)

find_program (FISH_PROGRAM fish)

mark_as_advanced (FORCE FISH_PROGRAM)

if(FISH_PROGRAM)
	add_executable (fish_shell IMPORTED GLOBAL)

	set_target_properties (fish_shell PROPERTIES IMPORTED_LOCATION "${FISH_PROGRAM}")

	oranges_set_shell_target_properties (
		TARGET
		fish_shell
		NAME
		fish
		STARTUP_SCRIPT
		"~/.config/fish/config.fish"
		LOG_FILE
		"~/.config/fish/fish_history*")

	add_executable (fish::fish ALIAS fish_shell)

	set (fish_FOUND TRUE)
endif()
