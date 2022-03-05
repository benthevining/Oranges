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

function(oranges_install_targets)

	set (oneValueArgs EXPORT REL_PATH)

	cmake_parse_arguments (ORANGES_ARG "OPTIONAL" "${oneValueArgs}" "TARGETS" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG EXPORT TARGETS)

	include (GNUInstallDirs)

	set (install_command TARGETS "${ORANGES_ARG_TARGETS}" EXPORT "${ORANGES_ARG_EXPORT}")

	if(ORANGES_ARG_REL_PATH)
		set (
			install_command
			${install_command} LIBRARY DESTINATION "${ORANGES_ARG_REL_PATH}" ARCHIVE DESTINATION
			"${ORANGES_ARG_REL_PATH}" RUNTIME DESTINATION "${ORANGES_ARG_REL_PATH}" INCLUDES
			DESTINATION include)
	else()
		set (
			install_command
			${install_command} LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" ARCHIVE DESTINATION
			"${CMAKE_INSTALL_LIBDIR}" RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" INCLUDES
			DESTINATION include)
	endif()

	if(ORANGES_ARG_OPTIONAL)
		set (install_command ${install_command} OPTIONAL)
	endif()

	install (${install_command})

endfunction()

#

macro(lemons_warn_if_not_processing_project)
	# if (NOT CMAKE_ROLE STREQUAL "PROJECT") message (AUTHOR_WARNING "This module
	# (${CMAKE_CURRENT_LIST_FILE}) isn't meant to be used outside of project configurations. Some
	# commands may not be available.") endif()
endmacro()
