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

#

function(_lemons_deprecated_variable_watch variableName access value current_file stack)
	message (DEPRECATION "${access} of deprecated variable ${variableName}!")
endfunction()

macro(lemons_deprecate_variable variableName)
	variable_watch ("${variableName}" _lemons_deprecated_variable_watch)
endmacro()

#

macro(lemons_deprecate_function functionName)
	if(NOT COMMAND ${functionName})
		message (
			AUTHOR_WARNING
				"Attempting to deprecate function ${functionName}, but command is not defined!")
	endif()

	function("${functionName}")
		message (DEPRECATION "Deprecated function ${functionName} called!")
		cmake_language (CALL "_${functionName}" ${ARGN})
	endfunction()
endmacro()

macro(lemons_deprecate_function_args prefix)
	foreach(argument ${ARGN})
		if(${prefix}_${argument})
			message (
				DEPRECATION
					"Deprecated function argument ${argument} used in call to ${CMAKE_CURRENT_FUNCTION}!"
				)
		endif()
	endforeach()
endmacro()
