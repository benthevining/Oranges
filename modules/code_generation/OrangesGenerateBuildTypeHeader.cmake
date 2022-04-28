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

#[=======================================================================[.rst:

OrangesGenerateBuildTypeHeader
-------------------------

This module provides the function :command:`oranges_generate_build_type_header()`.

Generating a build type header for a target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_generate_build_type_header

	oranges_generate_build_type_header (TARGET <targetName>
										[BASE_NAME <baseName>]
										[HEADER <exportHeaderName>]
										[INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>]
										[INTERFACE])

Generates a header file containing various macros identifiying the build type for the given target.

The generated header will contain the following macros:
<baseName>_DEBUG - 0 or 1
<baseName>_RELEASE - 0 or 1
<baseName>_BUILD_TYPE - string describing the current build type

Because a multiconfig generator may generate multiple headers at once (and they obviously must be separate files),
the way this works is that a header is generated for each build configuration, named <build_type_$<CONFIG>.h>,
and then one "wrapper header" is created, which includes the correct configuration header using compile definitions passed at build time.

The advantage of generating a header containing the build type macros, instead of simply passing them as compile definitions,
is that you can easily see exactly what the values are -- an age-old problem with preprocessor macros.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

#

function (oranges_generate_build_type_header)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET BASE_NAME HEADER INSTALL_COMPONENT REL_PATH)

	cmake_parse_arguments (ORANGES_ARG "INTERFACE" "${oneValueArgs}" "" ${ARGN})

	oranges_assert_target_argument_is_target (ORANGES_ARG)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if (NOT ORANGES_ARG_BASE_NAME)
		set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
	endif ()

	if (NOT ORANGES_ARG_HEADER)
		set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_build_type.h")
	endif ()

	string (TOUPPER "${ORANGES_ARG_BASE_NAME}" ORANGES_ARG_BASE_NAME)

	if (ORANGES_ARG_INTERFACE)
		set (public_vis INTERFACE)
	else ()
		set (public_vis PUBLIC)
	endif ()

	get_property (ORANGES_DEBUG_CONFIGS_LIST GLOBAL
				  PROPERTY DEBUG_CONFIGURATIONS)

	if (NOT ORANGES_DEBUG_CONFIGS_LIST)
		message (
			AUTHOR_WARNING
				"The global property DEBUG_CONFIGURATIONS must be defined in order for ${CMAKE_CURRENT_FUNCTION} to work correctly!"
			)

		set (ORANGES_DEBUG_CONFIGS_LIST Debug)
	endif ()

	set (intermediate_file_in
		 "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/build_type_header.h")
	set (intermediate_file
		 "${CMAKE_CURRENT_BINARY_DIR}/intermediate_build_type_header.h")

	configure_file ("${intermediate_file_in}" "${intermediate_file}" @ONLY
					NEWLINE_STYLE UNIX ESCAPE_QUOTES)

	set (configured_file "${CMAKE_CURRENT_BINARY_DIR}/build_type_$<CONFIG>.h")

	file (GENERATE OUTPUT "${configured_file}" INPUT "${intermediate_file}"
		  TARGET "${ORANGES_ARG_TARGET}" NEWLINE_STYLE UNIX)

	target_compile_definitions (
		"${ORANGES_ARG_TARGET}"
		"${public_vis}"
		"ORANGES_BUILD_TYPE_HEADER_NAME=<build_type_$<CONFIG>.h>")

	set (configured_includer
		 "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

	set (
		includer_input
		"${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/build_type_header_includer.h"
		)

	configure_file ("${includer_input}" "${configured_includer}" @ONLY
					NEWLINE_STYLE UNIX)

	set_property (
		DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
		PROPERTY CMAKE_CONFIGURE_DEPENDS "${intermediate_file_in}"
				 "${includer_input}")

	set_property (
		TARGET "${ORANGES_ARG_TARGET}" APPEND
		PROPERTY ADDITIONAL_CLEAN_FILES "${intermediate_file}"
				 "${configured_includer}")

	set_source_files_properties (
		"${configured_includer}" TARGET_DIRECTORY "${ORANGES_ARG_TARGET}"
		PROPERTIES GENERATED ON)

	target_sources (
		"${ORANGES_ARG_TARGET}"
		"${public_vis}"
		$<BUILD_INTERFACE:${configured_includer}>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>
		)

	if (ORANGES_ARG_INSTALL_COMPONENT)
		set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
	endif ()

	install (FILES "${configured_file}" "${configured_includer}"
			 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}"
			 ${install_component})

	target_include_directories (
		"${ORANGES_ARG_TARGET}" "${public_vis}"
		$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>
		)

endfunction ()
