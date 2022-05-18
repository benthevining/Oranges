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
----------------------------

This module is a thin wrapper around CMake's :command:`generate_export_header() <generate_export_header>`, and adds the :command:`oranges_generate_export_header() <generate_export_header>` command.

.. command:: oranges_generate_export_header

  ::

    oranges_generate_export_header (TARGET <targetName>
                                   [BASE_NAME <baseName>]
                                   [HEADER <exportHeaderName>]
                                   [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>])

Generates a header file containing symbol export macros, and adds it to the specified target.

``REL_PATH`` is the path below ``CMAKE_INSTALL_INCLUDEDIR`` where the generated header will be installed to. Defaults to ``<targetName>``.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Oranges::OrangesABIControlledLibrary``

Provides default symbol visibility control flags.

.. seealso ::

    Module :module:`GenerateExportHeader`
        OrangesGenerateExportHeader is a thin wrapper around this module shipped by CMake

    Module :module:`OrangesGenerateStandardHeaders`
        An aggregate module that includes this one

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

if (NOT TARGET Oranges::OrangesABIControlledLibrary)
    add_library (OrangesABIControlledLibrary INTERFACE)

    set_target_properties (OrangesABIControlledLibrary PROPERTIES CXX_VISIBILITY_PRESET hidden
                                                                  VISIBILITY_INLINES_HIDDEN TRUE)

    install (TARGETS OrangesABIControlledLibrary EXPORT OrangesTargets)

    add_library (Oranges::OrangesABIControlledLibrary ALIAS OrangesABIControlledLibrary)
endif ()

#

function (oranges_generate_export_header)

    # NB this include must be in this function's scope, to prevent bugs with this module's
    # variables!
    include (GenerateExportHeader)

    oranges_add_function_message_context ()

    set (options INTERFACE)
    set (oneValueArgs TARGET BASE_NAME HEADER REL_PATH INSTALL_COMPONENT)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "" ${ARGN})

    oranges_assert_target_argument_is_target (ORANGES_ARG)
    lemons_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
    endif ()

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_export.h")
    endif ()

    if (ORANGES_ARG_INTERFACE)
        set (public_vis INTERFACE)
        set (private_vis INTERFACE)
    else ()
        set (public_vis PUBLIC)
        set (private_vis PRIVATE)
    endif ()

    target_link_libraries ("${ORANGES_ARG_TARGET}" "${private_vis}"
                           $<BUILD_INTERFACE:Oranges::OrangesABIControlledLibrary>)

    generate_export_header ("${ORANGES_ARG_TARGET}" BASE_NAME "${ORANGES_ARG_BASE_NAME}"
                            EXPORT_FILE_NAME "${ORANGES_ARG_HEADER}" ${no_build_deprecated})

    if (NOT ORANGES_ARG_REL_PATH)
        set (ORANGES_ARG_REL_PATH "${ORANGES_ARG_TARGET}")
    endif ()

    set (generated_file "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

    set_source_files_properties ("${generated_file}" TARGET_DIRECTORY "${ORANGES_ARG_TARGET}"
                                 PROPERTIES GENERATED ON)

    target_sources (
        "${ORANGES_ARG_TARGET}"
        "${public_vis}"
        "$<BUILD_INTERFACE:${generated_file}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>"
        )

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    install (FILES "${generated_file}"
             DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}" ${install_component})

    target_include_directories (
        "${ORANGES_ARG_TARGET}" "${public_vis}" "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>")

    string (TOUPPER "${ORANGES_ARG_BASE_NAME}" upperBaseName)

    target_compile_definitions (
        "${ORANGES_ARG_TARGET}"
        "${public_vis}"
        "$<$<STREQUAL:$<TARGET_PROPERTY:${ORANGES_ARG_TARGET},TYPE>,STATIC_LIBRARY>:${upperBaseName}_STATIC_DEFINE=1>"
        )

endfunction ()
