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

find_program (SUDO sudo)

if(NOT SUDO)
	message (FATAL_ERROR "sudo is required on Linux!")
endif()

# use apt-get if available, else apt

find_program (APT_GET apt-get)

if(APT_GET)
	set (apt_program "${APT_GET}" CACHE INTERNAL "")
else()
	find_program (APT apt)

	if(APT)
		set (apt_program "${APT}" CACHE INTERNAL "")
	else()

		find_program (DNF dnf)

		if(DNF)
			set (apt_program "${DNF}" CACHE INTERNAL "")
		else()
			message (FATAL_ERROR "No package manager program can be found!")
		endif()
	endif()
endif()

#

function(_lemons_deps_os_update_func)

	execute_process (COMMAND "${SUDO}" ${apt_program} update COMMAND_ECHO STDOUT)

	execute_process (COMMAND "${SUDO}" ${apt_program} upgrade COMMAND_ECHO STDOUT)

endfunction()

#

function(_lemons_deps_os_install_func deps)

	execute_process (COMMAND "${SUDO}" ${apt_program} install -y --no-install-recommends ${deps}
							 COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

endfunction()
