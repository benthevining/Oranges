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

This module provides the function :command:`oranges_generate_standard_headers() <oranges_generate_standard_headers>`.

.. command:: oranges_generate_standard_headers

  ::

    oranges_generate_standard_headers (TARGET <targetName>
                                      [BASE_NAME <baseName>]
                                      [HEADER <mainHeaderName>] | [NO_AGGREGATE_HEADER]
                                      [FEATURE_TEST_LANGUAGE <lang>]
                                      [EXPORT_HEADER <exportHeaderName>]
                                      [PLATFORM_HEADER <platformHeaderName>]
                                      [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>]
                                      [INTERFACE]
                                      [SOURCE_GROUP_NAME <groupName>])

This calls :command:`oranges_generate_export_header() <oranges_generate_export_header>` and :command:`oranges_generate_platform_header() <oranges_generate_platform_header>`,
then generates another header named ``<mainHeaderName>`` that includes the other generated headers.

``REL_PATH`` is the path below ``CMAKE_INSTALL_INCLUDEDIR`` where the generated header will be installed to. Defaults to ``<targetName>``.

If the ``NO_AGGREGATE_HEADER`` option is present, then one "central" header that includes the other generated headers will not be created.

``FEATURE_TEST_LANGUAGE`` is the language passed to :command:`oranges_generate_platform_header() <oranges_generate_platform_header>` to do any compiler-specific platform introspection; defaults to the value of :variable:`PLAT_DEFAULT_TESTING_LANGUAGE`.

All headers will be added to the target with ``PUBLIC`` visibility by default, unless the ``INTERFACE`` keyword is given.

If ``SOURCE_GROUP_NAME`` is given, then the generated files will be grouped into a source folder using the :external:command:`source_group() <source_group>` command. The group will be named ``<groupName>``.

.. seealso ::

    Module :module:`OrangesGeneratePlatformHeader`
        This module provides platform- and compiler-specific macro definitions

    Module :module:`OrangesGenerateExportHeader`
        This module provides symbol visibility control utilities

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)
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
        set (ORANGES_ARG_FEATURE_TEST_LANGUAGE "${PLAT_DEFAULT_TESTING_LANGUAGE}")
    endif ()

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
    endif ()

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_TARGET}_generated.h")
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

        set (generated_files "${ORANGES_ARG_EXPORT_HEADER}" "${ORANGES_ARG_PLATFORM_HEADER}"
                             "${ORANGES_ARG_HEADER}")

        list (TRANSFORM generated_files PREPEND "${CMAKE_CURRENT_BINARY_DIR}" OUTPUT_VARIABLE
                                                                              build_tree_files)

        source_group (TREE "${CMAKE_CURRENT_BINARY_DIR}" PREFIX "${ORANGES_ARG_SOURCE_GROUP_NAME}"
                      FILES ${build_tree_files})

        set (install_dest
             "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}")

        list (TRANSFORM generated_files PREPEND "${install_dest}" OUTPUT_VARIABLE
                                                                  install_tree_files)

        source_group (TREE "${install_dest}" PREFIX "${ORANGES_ARG_SOURCE_GROUP_NAME}"
                      FILES ${install_tree_files})
    endif ()

endfunction ()
