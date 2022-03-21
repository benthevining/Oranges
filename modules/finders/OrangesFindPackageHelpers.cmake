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
include (FindPackageMessage)
include (LemonsCmakeDevTools)

#

macro(find_package_warning_or_error message_text)
	if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
		message (FATAL_ERROR "${message_text}")
	endif()

	if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
		message (WARNING "${message_text}")
	endif()
endmacro()

#

function(find_package_execute_process)

	set (oneValueArgs WORKING_DIRECTORY)
	set (multiValueArgs COMMAND)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG COMMAND)

	if(ORANGES_ARG_WORKING_DIRECTORY)
		set (dir_flag WORKING_DIRECTORY "${ORANGES_ARG_WORKING_DIRECTORY}")
	endif()

	if(${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
		set (quiet_flag OUTPUT_QUIET ERROR_QUIET)
	else()
		set (quiet_flag COMMAND_ECHO STDOUT)
	endif()

	if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND ${ORANGES_ARG_COMMAND} ${dir_flag} ${quiet_flag} ${error_flag})

endfunction()
