# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

include_guard (GLOBAL)

find_program (CHOCO choco)

if(NOT CHOCO)
	unset (CACHE{CHOCO})

	find_program (POWERSHELL powershell)

	if(NOT POWERSHELL)
		message (
			FATAL_ERROR "powershell is required for installing Chocolatey, and cannot be found!")
	endif()

	message (STATUS "Installing Chocolatey...")

	execute_process (COMMAND ${POWERSHELL} Set-ExecutionPolicy Bypass COMMAND_ECHO STDOUT)

	execute_process (
		COMMAND
			${POWERSHELL} iex
			"((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
			COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

	find_program (CHOCO choco)

	if(NOT CHOCO)
		message (FATAL_ERROR "Error installing Chocolatey!")
	endif()
endif()

#

function(_lemons_deps_os_update_func)

	execute_process (COMMAND "${CHOCO}" update all COMMAND_ECHO STDOUT)

endfunction()

#

function(_lemons_deps_os_install_func deps)

	execute_process (COMMAND "${CHOCO}" install ${deps} -y COMMAND_ECHO STDOUT
							 COMMAND_ERROR_IS_FATAL ANY)

endfunction()
