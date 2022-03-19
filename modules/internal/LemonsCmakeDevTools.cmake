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

function(oranges_export_alias_target origTarget namespace)
	if(NOT TARGET "${namespace}::${origTarget}")
		add_library ("${namespace}::${origTarget}" ALIAS "${origTarget}")
	endif()
endfunction()

#

function(oranges_install_targets)

	set (oneValueArgs EXPORT REL_PATH RUNTIME_COMPONENT DEV_COMPONENT COMPONENT_PREFIX)

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

	set (install_command TARGETS "${ORANGES_ARG_TARGETS}" EXPORT "${ORANGES_ARG_EXPORT}")

	if(ORANGES_ARG_OPTIONAL)
		set (install_command ${install_command} OPTIONAL)
	endif()

	if(ORANGES_ARG_REL_PATH)
		set (lib_dest "${CMAKE_INSTALL_LIBDIR}/${ORANGES_ARG_REL_PATH}")
		set (archive_dest "${CMAKE_INSTALL_LIBDIR}/${ORANGES_ARG_REL_PATH}")
		set (runtime_dest "${CMAKE_INSTALL_BINDIR}/${ORANGES_ARG_REL_PATH}")
	else()
		set (lib_dest "${CMAKE_INSTALL_LIBDIR}")
		set (archive_dest "${CMAKE_INSTALL_LIBDIR}")
		set (runtime_dest "${CMAKE_INSTALL_BINDIR}")
	endif()

	install (
		${install_command}
		LIBRARY
		DESTINATION
		"${lib_dest}"
		COMPONENT
		"${ORANGES_ARG_RUNTIME_COMPONENT}"
		NAMELINK_COMPONENT
		"${ORANGES_ARG_DEV_COMPONENT}"
		ARCHIVE
		DESTINATION
		"${archive_dest}"
		COMPONENT
		"${ORANGES_ARG_DEV_COMPONENT}"
		RUNTIME
		DESTINATION
		"${runtime_dest}"
		COMPONENT
		"${ORANGES_ARG_RUNTIME_COMPONENT}"
		INCLUDES
		DESTINATION
		"${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}")
endfunction()

#

function(oranges_add_target_headers)

	set (oneValueArgs TARGET SCOPE REL_PATH)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "FILES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET SCOPE)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT TARGET "${ORANGES_ARG_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} given target name ${ORANGES_ARG_TARGET}, but target does not exist!"
			)
	endif()

	foreach(headerFile ${ORANGES_ARG_FILES})
		target_sources (
			"${ORANGES_ARG_TARGET}" "${ORANGES_ARG_SCOPE}"
									$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${headerFile}>)

		if(ORANGES_ARG_REL_PATH)
			target_sources (
				"${ORANGES_ARG_TARGET}"
				"${ORANGES_ARG_SCOPE}"
				$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${headerFile}>
				)

			install (FILES "${CMAKE_CURRENT_LIST_DIR}/${headerFile}"
					 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}")
		else()
			target_sources (
				"${ORANGES_ARG_TARGET}"
				"${ORANGES_ARG_SCOPE}"
				$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${headerFile}>)

			install (FILES "${CMAKE_CURRENT_LIST_DIR}/${headerFile}"
					 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
		endif()
	endforeach()

	target_include_directories (
		"${ORANGES_ARG_TARGET}" "${ORANGES_ARG_SCOPE}"
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction()

#

macro(lemons_warn_if_not_processing_project)
	# if (NOT CMAKE_ROLE STREQUAL "PROJECT") message (AUTHOR_WARNING "This module
	# (${CMAKE_CURRENT_LIST_FILE}) isn't meant to be used outside of project configurations. Some
	# commands may not be available.") endif()
endmacro()
