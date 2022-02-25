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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

#

function(_lemons_const_variable_watch variableName access)
	if(access STREQUAL "WRITE_ACCESS")
		message (AUTHOR_WARNING "Writing to const variable ${variableName}!")
	endif()
endfunction()

macro(lemons_make_variable_const variable)
	variable_watch (${variableName} _lemons_const_variable_watch)
endmacro()

#

macro(lemons_require_function_arguments prefix)
	foreach(requiredArgument ${ARGN})
		if(NOT ${prefix}_${requiredArgument})
			message (
				FATAL_ERROR
					"Required argument ${requiredArgument} not specified in call to ${CMAKE_CURRENT_FUNCTION}!"
				)
		endif()
	endforeach()
endmacro()

macro(lemons_check_for_unparsed_args prefix)
	if(${prefix}_UNPARSED_ARGUMENTS)
		message (
			FATAL_ERROR
				"Unparsed arguments ${${prefix}_UNPARSED_ARGUMENTS} found in call to ${CMAKE_CURRENT_FUNCTION}!"
			)
	endif()
endmacro()

#

macro(lemons_warn_if_not_processing_project)
	# if (NOT CMAKE_ROLE STREQUAL "PROJECT") message (AUTHOR_WARNING "This module
	# (${CMAKE_CURRENT_LIST_FILE}) isn't meant to be used outside of project configurations. Some
	# commands may not be available.") endif()
endmacro()
