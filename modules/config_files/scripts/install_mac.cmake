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

find_program (HOMEBREW brew)

if(NOT HOMEBREW)
	unset (CACHE{HOMEBREW})

	find_program (BASH bash)

	if(NOT BASH)
		message (FATAL_ERROR "bash is required for installing Homebrew, and cannot be found!")
	endif()

	message (STATUS "Installing Homebrew...")

	execute_process (COMMAND "${BASH}" "${CMAKE_CURRENT_LIST_DIR}/mac_install_homebrew.sh"
							 COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

	find_program (HOMEBREW brew)

	if(NOT HOMEBREW)
		message (FATAL_ERROR "Error installing Homebrew!")
	endif()
endif()

#

function(_lemons_deps_os_update_func)

	execute_process (COMMAND "${HOMEBREW}" update COMMAND_ECHO STDOUT)

	execute_process (COMMAND "${HOMEBREW}" upgrade COMMAND_ECHO STDOUT)

endfunction()

#

function(_lemons_deps_os_install_func deps)

	execute_process (COMMAND "${HOMEBREW}" install ${deps} COMMAND_ECHO STDOUT
							 COMMAND_ERROR_IS_FATAL ANY)

endfunction()
