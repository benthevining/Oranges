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

OrangesGenerateExportHeader
-------------------------

This module is a thin wrapper around CMake's generate_export_header, and adds the :command:`oranges_generate_export_header()` command.

Generating an export header for a target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_generate_export_header

	oranges_generate_export_header (TARGET <targetName>
									[BASE_NAME <baseName>]
									[HEADER <exportHeaderName>])

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

add_library (OrangesABIControlledLibrary INTERFACE)

set_target_properties (OrangesABIControlledLibrary PROPERTIES CXX_VISIBILITY_PRESET hidden
															  VISIBILITY_INLINES_HIDDEN TRUE)

oranges_export_alias_target (OrangesABIControlledLibrary Oranges)

oranges_install_targets (TARGETS OrangesABIControlledLibrary EXPORT OrangesTargets)

option (ORANGES_REMOVE_DEPRECATED_CODE "Removes deprecated code from preprocessed output" OFF)

mark_as_advanced (FORCE ORANGES_REMOVE_DEPRECATED_CODE)

#

function(oranges_generate_export_header)

	# NB this include must be in this function's scope, to prevent bugs with this module's
	# variables!
	include (GenerateExportHeader)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET BASE_NAME HEADER REL_PATH)

	cmake_parse_arguments (ORANGES_ARG "INTERFACE" "${oneValueArgs}" "" ${ARGN})

	oranges_assert_target_argument_is_target (ORANGES_ARG)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_BASE_NAME)
		set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
	endif()

	if(NOT ORANGES_ARG_HEADER)
		set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_export.h")
	endif()

	string (TOUPPER "${ORANGES_ARG_BASE_NAME}" upperBaseName)

	if(ORANGES_ARG_INTERFACE)
		set (public_vis INTERFACE)
		set (private_vis INTERFACE)
	else()
		set (public_vis PUBLIC)
		set (private_vis PRIVATE)
	endif()

	target_link_libraries ("${ORANGES_ARG_TARGET}" "${private_vis}"
						   Oranges::OrangesABIControlledLibrary)

	set_target_properties (
		"${ORANGES_ARG_TARGET}" PROPERTIES COMPILE_FLAGS
										   -D${upperBaseName}SHARED_AND_STATIC_STATIC_DEFINE)

	if(ORANGES_REMOVE_DEPRECATED_CODE)
		set (no_build_deprecated DEFINE_NO_DEPRECATED)
	endif()

	generate_export_header ("${ORANGES_ARG_TARGET}" BASE_NAME "${ORANGES_ARG_BASE_NAME}"
							EXPORT_FILE_NAME "${ORANGES_ARG_HEADER}" ${no_build_deprecated})

	if(NOT ORANGES_ARG_REL_PATH)
		set (ORANGES_ARG_REL_PATH "${ORANGES_ARG_TARGET}")
	endif()

	oranges_add_target_headers (
		TARGET
		"${ORANGES_ARG_TARGET}"
		SCOPE
		"${public_vis}"
		REL_PATH
		"${ORANGES_ARG_REL_PATH}"
		FILES
		"${ORANGES_ARG_HEADER}"
		BINARY_DIR)

	target_include_directories (
		"${ORANGES_ARG_TARGET}" "${public_vis}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction()
