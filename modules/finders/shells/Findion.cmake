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

set_package_properties (ion PROPERTIES URL "" DESCRIPTION "UNIX shell")

oranges_file_scoped_message_context ("Findion")

set (ion_FOUND FALSE)

find_program (ION_PROGRAM ion)

mark_as_advanced (FORCE ION_PROGRAM)

if(ION_PROGRAM)
	add_executable (ion_shell IMPORTED GLOBAL)

	set_target_properties (ion_shell PROPERTIES IMPORTED_LOCATION "${ION_PROGRAM}")

	oranges_set_shell_target_properties (
		TARGET
		ion_shell
		NAME
		ion
		STARTUP_SCRIPT
		"~/.config/ion/initrc"
		LOG_FILE
		"~/.local/share/ion/history")

	add_executable (ion::ion ALIAS ion_shell)

	set (ion_FOUND TRUE)
endif()
