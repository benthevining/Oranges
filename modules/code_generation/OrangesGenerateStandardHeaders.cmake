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

OrangesGenerateStandardHeaders
-------------------------------

This module provides the function :command:`oranges_generate_standard_headers()`.

.. command:: oranges_generate_standard_headers

  ::

    oranges_generate_standard_headers (TARGET <targetName>
                                      [BASE_NAME <baseName>]
                                      [HEADER <mainHeaderName>] | [NO_AGGREGATE_HEADER]
                                      [FEATURE_TEST_LANGUAGE <lang>]
                                      [BUILD_TYPE_HEADER <buildTypeHeaderName>]
                                      [EXPORT_HEADER <exportHeaderName>]
                                      [PLATFORM_HEADER <platformHeaderName>]
                                      [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>]
                                      [INTERFACE]
                                      [SOURCE_GROUP_NAME <groupName>])

This calls :command:`oranges_generate_build_type_header()`, :command:`oranges_generate_export_header()`, and :command:`oranges_generate_platform_header()`,
then generates another header named ``<mainHeaderName>`` that includes all the other generated headers.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)
include (OrangesGenerateBuildTypeHeader)
include (OrangesGenerateExportHeader)
include (OrangesGeneratePlatformHeader)

#

function (oranges_generate_standard_headers)

    oranges_add_function_message_context ()

    set (options INTERFACE NO_AGGREGATE_HEADER)

    set (
        oneValueArgs
        TARGET
        BASE_NAME
        HEADER
        BUILD_TYPE_HEADER
        EXPORT_HEADER
        PLATFORM_HEADER
        INSTALL_COMPONENT
        REL_PATH
        FEATURE_TEST_LANGUAGE
        SOURCE_GROUP_NAME)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "" ${ARGN})

    oranges_assert_target_argument_is_target (ORANGES_ARG)
    lemons_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_FEATURE_TEST_LANGUAGE)
        set (ORANGES_ARG_FEATURE_TEST_LANGUAGE CXX)
    endif ()

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
    endif ()

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_TARGET}_generated.h")
    endif ()

    if (NOT ORANGES_ARG_BUILD_TYPE_HEADER)
        set (ORANGES_ARG_BUILD_TYPE_HEADER "${ORANGES_ARG_TARGET}_build_type.h")
    endif ()

    if (NOT ORANGES_ARG_EXPORT_HEADER)
        set (ORANGES_ARG_EXPORT_HEADER "${ORANGES_ARG_TARGET}_export.h")
    endif ()

    if (NOT ORANGES_ARG_PLATFORM_HEADER)
        set (ORANGES_ARG_PLATFORM_HEADER "${ORANGES_ARG_TARGET}_platform.h")
    endif ()

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component INSTALL_COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    if (ORANGES_ARG_REL_PATH)
        set (relative_path REL_PATH "${ORANGES_ARG_REL_PATH}")
    endif ()

    oranges_generate_export_header (
        TARGET "${ORANGES_ARG_TARGET}" BASE_NAME "${ORANGES_ARG_BASE_NAME}"
        HEADER "${ORANGES_ARG_EXPORT_HEADER}" ${install_component} ${relative_path})

    if (ORANGES_ARG_INTERFACE)
        set (interface_flag INTERFACE)
    endif ()

    oranges_generate_build_type_header (
        TARGET "${ORANGES_ARG_TARGET}" BASE_NAME "${ORANGES_ARG_BASE_NAME}"
        HEADER "${ORANGES_ARG_BUILD_TYPE_HEADER}" ${install_component} ${relative_path}
                                                  ${interface_flag})

    oranges_generate_platform_header (
        TARGET "${ORANGES_ARG_TARGET}"
        BASE_NAME "${ORANGES_ARG_BASE_NAME}"
        HEADER "${ORANGES_ARG_PLATFORM_HEADER}"
        LANGUAGE "${ORANGES_ARG_FEATURE_TEST_LANGUAGE}" ${install_component} ${relative_path}
                                                        ${interface_flag})

    if (NOT ORANGES_ARG_NO_AGGREGATE_HEADER)
        set (configured_file "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

        set (input_file "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/standard_header.h")

        configure_file ("${input_file}" "${configured_file}" @ONLY NEWLINE_STYLE UNIX)

        set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND CMAKE_CONFIGURE_DEPENDS
                                                            "${input_file}")

        set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                     "${configured_file}")

        set_source_files_properties ("${configured_file}" TARGET_DIRECTORY "${ORANGES_ARG_TARGET}"
                                     PROPERTIES GENERATED ON)

        if (ORANGES_ARG_INTERFACE)
            set (public_vis INTERFACE)
        else ()
            set (public_vis PUBLIC)
        endif ()

        target_sources (
            "${ORANGES_ARG_TARGET}"
            "${public_vis}"
            $<BUILD_INTERFACE:${configured_file}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>
            )

        if (ORANGES_ARG_INSTALL_COMPONENT)
            set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
        endif ()

        install (FILES "${configured_file}"
                 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}"
                 ${install_component})

        target_include_directories (
            "${ORANGES_ARG_TARGET}" "${public_vis}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)
    endif ()

    if (ORANGES_ARG_SOURCE_GROUP_NAME)
        source_group (
            TREE "${CMAKE_CURRENT_BINARY_DIR}"
            PREFIX "${ORANGES_ARG_SOURCE_GROUP_NAME}"
            FILES ${configured_file} "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_EXPORT_HEADER}"
                  "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_BUILD_TYPE_HEADER}"
                  "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_PLATFORM_HEADER}")
    endif ()

endfunction ()
