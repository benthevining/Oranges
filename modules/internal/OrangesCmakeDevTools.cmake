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

function(_lemons_const_variable_watch variableName access value current_file stack)
	if(access STREQUAL "WRITE_ACCESS")
		message (AUTHOR_WARNING "Writing to const variable ${variableName}!")
	endif()
endfunction()

macro(lemons_make_variable_const variable)
	variable_watch ("${variableName}" _lemons_const_variable_watch)
endmacro()

#

function(get_required_target_property output target property)
	if(NOT TARGET ${target})
		message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${target}!")
	endif()

	get_target_property (property_value "${target}" "${property}")

	if(NOT property_value)
		message (FATAL_ERROR "Error retrieving property ${property} from target ${target}!")
	endif()

	set (${output} ${property_value} PARENT_SCOPE)
endfunction()

#

function(oranges_export_alias_target origTarget namespace)
	if(NOT TARGET "${namespace}::${origTarget}")
		add_library ("${namespace}::${origTarget}" ALIAS "${origTarget}")
	endif()
endfunction()

#

function(oranges_install_targets)

	set (oneValueArgs EXPORT REL_PATH RUNTIME_COMPONENT DEV_COMPONENT COMPONENT_PREFIX
					  COMPONENT_GROUP)

	cmake_parse_arguments (ORANGES_ARG "OPTIONAL" "${oneValueArgs}" "TARGETS" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG EXPORT TARGETS)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_RUNTIME_COMPONENT)
		if(ORANGES_ARG_COMPONENT_PREFIX)
			set (ORANGES_ARG_RUNTIME_COMPONENT "${ORANGES_ARG_COMPONENT_PREFIX}_Runtime")
		else()
			set (ORANGES_ARG_RUNTIME_COMPONENT "${PROJECT_NAME}_Runtime")
		endif()
	endif()

	set ("CPACK_COMPONENT_${ORANGES_ARG_RUNTIME_COMPONENT}_GROUP" Runtime)

	set (CPACK_COMPONENT_GROUP_Runtime_DESCRIPTION
		 "Installs all available runtime artifacts and executables")

	if(NOT DEV_COMPONENT)
		if(ORANGES_ARG_COMPONENT_PREFIX)
			set (ORANGES_ARG_DEV_COMPONENT "${ORANGES_ARG_COMPONENT_PREFIX}_Development")
		else()
			set (ORANGES_ARG_DEV_COMPONENT "${PROJECT_NAME}_Development")
		endif()
	endif()

	set ("CPACK_COMPONENT_${ORANGES_ARG_COMPONENT_PREFIX}_GROUP" Development)

	set (CPACK_COMPONENT_GROUP_Development_DESCRIPTION
		 "Installs all available development artifacts")

	if(ORANGES_ARG_OPTIONAL)
		set (optional_flag OPTIONAL)
	endif()

	install (
		TARGETS "${ORANGES_ARG_TARGETS}"
		EXPORT "${ORANGES_ARG_EXPORT}"
		${optional_flag}
		LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT "${ORANGES_ARG_RUNTIME_COMPONENT}"
				NAMELINK_COMPONENT "${ORANGES_ARG_DEV_COMPONENT}"
		ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT "${ORANGES_ARG_DEV_COMPONENT}"
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT "${ORANGES_ARG_RUNTIME_COMPONENT}"
		INCLUDES
		DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}")

	if(ORANGES_ARG_COMPONENT_GROUP)
		include (CPackComponent)

		cpack_add_component ("${ORANGES_ARG_RUNTIME_COMPONENT}"
							 GROUP "${ORANGES_ARG_COMPONENT_GROUP}")

		cpack_add_component ("${ORANGES_ARG_DEV_COMPONENT}" GROUP "${ORANGES_ARG_COMPONENT_GROUP}")
	endif()
endfunction()

#

function(oranges_add_target_headers)

	set (oneValueArgs TARGET SCOPE REL_PATH INSTALL_COMPONENT)

	cmake_parse_arguments (ORANGES_ARG "BINARY_DIR" "${oneValueArgs}" "FILES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET SCOPE)
	lemons_check_for_unparsed_args (ORANGES_ARG)
	oranges_assert_target_argument_is_target (ORANGES_ARG)

	foreach(headerFile ${ORANGES_ARG_FILES})

		if(ORANGES_ARG_BINARY_DIR)
			set (header_file_abs_path "${CMAKE_CURRENT_BINARY_DIR}/${headerFile}")
		else()
			set (header_file_abs_path "${CMAKE_CURRENT_LIST_DIR}/${headerFile}")
		endif()

		if(NOT EXISTS "${header_file_abs_path}")
			message (
				WARNING
					"${CMAKE_CURRENT_FUNCTION} - Header file ${header_file_abs_path} cannot be found!"
				)
			continue ()
		endif()

		target_sources ("${ORANGES_ARG_TARGET}" "${ORANGES_ARG_SCOPE}"
												$<BUILD_INTERFACE:${header_file_abs_path}>)

		if(ORANGES_ARG_REL_PATH)
			set (header_dir "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}")
		else()
			set (header_dir "${CMAKE_INSTALL_INCLUDEDIR}")
		endif()

		if(ORANGES_ARG_INSTALL_COMPONENT)
			set (component_flag COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
		endif()

		target_sources ("${ORANGES_ARG_TARGET}" "${ORANGES_ARG_SCOPE}"
												$<INSTALL_INTERFACE:${header_dir}/${headerFile}>)

		install (FILES "${header_file_abs_path}" DESTINATION "${header_dir}" ${component_flag})
	endforeach()

	target_include_directories (
		"${ORANGES_ARG_TARGET}" "${ORANGES_ARG_SCOPE}"
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction()

#

macro(lemons_warn_if_not_processing_project)
	if(NOT "${CMAKE_ROLE}" STREQUAL "PROJECT")
		message (
			AUTHOR_WARNING
				"This module (${CMAKE_CURRENT_LIST_FILE}) isn't meant to be used outside of project configurations. Some commands may not be available."
			)
	endif()
endmacro()

macro(lemons_error_if_not_processing_project)
	if(NOT "${CMAKE_ROLE}" STREQUAL "PROJECT")
		message (
			FATAL_ERROR
				"This module (${CMAKE_CURRENT_LIST_FILE}) cannot be used outside of project configurations!"
			)
	endif()
endmacro()

#

macro(oranges_add_function_message_context)
	list (APPEND CMAKE_MESSAGE_CONTEXT "${CMAKE_CURRENT_FUNCTION}")
endmacro()

macro(oranges_file_scoped_message_context context_msg)
	# if("${CMAKE_ROLE}" STREQUAL "PROJECT")
	list (APPEND CMAKE_MESSAGE_CONTEXT "${context_msg}")

	cmake_language (DEFER CALL list POP_BACK CMAKE_MESSAGE_CONTEXT)
	# endif()
endmacro()
