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

include (GNUInstallDirs)
include (OrangesFunctionArgumentHelpers)

#

function (_lemons_const_variable_watch variableName access value current_file
		  stack)
	if (access STREQUAL "WRITE_ACCESS")
		message (AUTHOR_WARNING "Writing to const variable ${variableName}!")
	endif ()
endfunction ()

macro (lemons_make_variable_const variable)
	variable_watch ("${variableName}" _lemons_const_variable_watch)
endmacro ()

macro (oranges_set_const variable value)
	set ("${variable}" "${value}")
	lemons_make_variable_const ("${variable}")
endmacro ()

#

function (get_required_target_property output target property)
	if (NOT TARGET ${target})
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${target}!"
			)
	endif ()

	get_target_property (property_value "${target}" "${property}")

	if (NOT property_value)
		message (
			FATAL_ERROR
				"Error retrieving property ${property} from target ${target}!")
	endif ()

	set (${output} ${property_value} PARENT_SCOPE)
endfunction ()

#

macro (lemons_warn_if_not_processing_project)
	if (NOT "${CMAKE_ROLE}" STREQUAL "PROJECT")
		message (
			AUTHOR_WARNING
				"This module (${CMAKE_CURRENT_LIST_FILE}) isn't meant to be used outside of project configurations. Some commands may not be available."
			)
	endif ()
endmacro ()

macro (lemons_error_if_not_processing_project)
	if (NOT "${CMAKE_ROLE}" STREQUAL "PROJECT")
		message (
			FATAL_ERROR
				"This module (${CMAKE_CURRENT_LIST_FILE}) cannot be used outside of project configurations!"
			)
	endif ()
endmacro ()

#

macro (oranges_add_function_message_context)
	list (APPEND CMAKE_MESSAGE_CONTEXT "${CMAKE_CURRENT_FUNCTION}")
endmacro ()

macro (oranges_file_scoped_message_context context_msg)
	# if("${CMAKE_ROLE}" STREQUAL "PROJECT")
	list (APPEND CMAKE_MESSAGE_CONTEXT "${context_msg}")

	cmake_language (DEFER CALL list POP_BACK CMAKE_MESSAGE_CONTEXT)
	# endif()
endmacro ()

#

# returns true if only a single one of its arguments is true
function (xor result)
	set (true_args_count 0)

	foreach (foo ${ARGN})
		if (foo)
			math (EXPR true_args_count "${true_args_count}+1")
		endif ()
	endforeach ()

	if (NOT (${true_args_count} EQUAL 1))
		set (${result} FALSE PARENT_SCOPE)
	else ()
		set (${result} TRUE PARENT_SCOPE)
	endif ()
endfunction ()

function (at_most_one result)
	set (true_args_count 0)

	foreach (foo ${ARGN})
		if (foo)
			math (EXPR true_args_count "${true_args_count}+1")
		endif ()
	endforeach ()

	if (${true_args_count} GREATER 1)
		set (${result} FALSE PARENT_SCOPE)
	else ()
		set (${result} TRUE PARENT_SCOPE)
	endif ()
endfunction ()
