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

set_package_properties (PowerShell PROPERTIES URL "" DESCRIPTION "Windows shell")

oranges_file_scoped_message_context ("FindPowerShell")

set (PowerShell_FOUND FALSE)

find_program (POWERSHELL_PROGRAM PowerShell)

mark_as_advanced (FORCE POWERSHELL_PROGRAM)

if(POWERSHELL_PROGRAM)
	add_executable (powershell IMPORTED GLOBAL)

	set_target_properties (powershell PROPERTIES IMPORTED_LOCATION "${POWERSHELL_PROGRAM}")

	oranges_set_shell_target_properties (
		TARGET powershell NAME PowerShell STARTUP_SCRIPT
		"%USERPROFILE%\\Documents \\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1")

	add_executable (PowerShell::PowerShell ALIAS powershell)

	set (PowerShell_FOUND TRUE)
endif()
