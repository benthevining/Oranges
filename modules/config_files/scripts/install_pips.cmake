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

find_program (PYTHON NAMES python3)

if(NOT PYTHON)
	message (
		FATAL_ERROR
			"Python interpreter cannot be found! Make sure it is listed as one of the dependencies in your default category or the category you're trying to install."
		)
endif()

execute_process (COMMAND ${PYTHON} -m ensurepip --upgrade COMMAND_ECHO STDOUT)

execute_process (COMMAND ${PYTHON} -m pip3 install --upgrade pip3)

#

function(lemons_install_python_pips pips)

	execute_process (COMMAND pip3 install --upgrade ${pips})

endfunction()
