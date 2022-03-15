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

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (Pip PROPERTIES URL "" DESCRIPTION "Python package manager")

set (Pip_FOUND FALSE)

find_package (Python3 COMPONENTS Interpreter)

if(Pip_FIND_REQUIRED AND NOT Python3_FOUND)
	message (FATAL_ERROR "Python interpreter cannot be found!")
endif()

execute_process (COMMAND Python3::Interpreter -m ensurepip --upgrade COMMAND_ECHO STDOUT)

execute_process (COMMAND Python3::Interpreter -m pip3 install --upgrade pip3 COMMAND_ECHO STDOUT)

find_program (PIP3 pip3)

mark_as_advanced (FORCE PIP3)

if(PIP3)
	set (Pip_FOUND TRUE)

	add_executable (Pip IMPORTED GLOBAL)

	set_target_properties (Pip PROPERTIES IMPORTED_LOCATION "${PIP3}")

	add_executable (Python3::Pip ALIAS Pip)

elseif(Pip_FIND_REQUIRED)
	message (FATAL_ERROR "Error installing pip!")
endif()

#

function(pip_upgrade_all)

	if(NOT TARGET Python3::Pip)
		message (FATAL_ERROR "Pip3 cannot be found!")
	endif()

	execute_process (COMMAND Python3::Pip list --outdated --format=freeze COMMAND grep -v "'^\\-e'"
					 COMMAND cut -d = -f 1 COMMAND xargs -n1 pip install -U COMMAND_ECHO STDOUT)

endfunction()

#

function(pip_install_packages)

	if(NOT TARGET Python3::Pip)
		message (FATAL_ERROR "Pip3 cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "PACKAGES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	if(ORANGES_ARG_UPDATE_FIRST)
		pip_upgrade_all ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND Python3::Pip install --upgrade ${ORANGES_ARG_PACKAGES} COMMAND_ECHO
							 STDOUT ${error_flag})

endfunction()
