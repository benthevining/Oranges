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

    oranges_generate_standard_headers (<targetName>
                                      [BASE_NAME <baseName>]
                                      [HEADER <mainHeaderName>] | [NO_AGGREGATE_HEADER]
                                      [FEATURE_TEST_LANGUAGE <lang>]
                                      [EXPORT_HEADER <exportHeaderName>]
                                      [PLATFORM_HEADER <platformHeaderName>]
                                      [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>]
                                      [SCOPE <PUBLIC|PRIVATE|INTERFACE>]
                                      [SOURCE_GROUP_NAME <groupName>])

This command calls :command:`oranges_generate_export_header() <oranges_generate_export_header>` and :command:`oranges_generate_platform_header() <oranges_generate_platform_header>`,
then generates another header named ``<mainHeaderName>`` that includes the other generated headers.

Options:

``BASE_NAME``
 Prefix used for all macros defined in generated header files, and the build type macros. Defaults to ``<targetName>``.

``HEADER``
 Name of the aggregate header file that will include all the other generated headers. Defaults to ``<baseName>_generated.h``.

 *Mutually exclusive with:* ``NO_AGGREGATE_HEADER``

``NO_AGGREGATE_HEADER``
 If specified, no "aggregate" header including the other generated headers will be created.

 *Mutually exclusive with:* ``HEADER``

``FEATURE_TEST_LANGUAGE``
 The language passed to :command:`oranges_generate_platform_header() <oranges_generate_platform_header>` to do any compiler-specific platform introspection. Defaults to the value of the :variable:`PLAT_DEFAULT_TESTING_LANGUAGE` variable.

``EXPORT_HEADER``
 Name of the export header to be generated. Defaults to ``<baseName>_export.h``.

``PLATFORM_HEADER``
 Name of the platform header to be generated. Defaults to ``<baseName>_platform.h``.

``NO_BUILD_TYPE_MACROS``
 If specified, build type macros will not be added to the target. The default behavior is to call :command:`oranges_add_build_type_macros() <oranges_add_build_type_macros>` to add compile definitions describing the build type to the target.

``INSTALL_COMPONENT``
 The name of an install component for all generated files to be added to. This command will not create the install component.

``REL_PATH``
 Path below ``CMAKE_INSTALL_INCLUDEDIR`` where the generated header will be installed to. Defaults to ``<targetName>``.

``SCOPE``
 The scope with which the build type macros and generated files will be added to the target. Defaults to ``INTERFACE`` for interface library targets, ``PRIVATE`` for executables, and ``PUBLIC`` for all other target types.

``SOURCE_GROUP_NAME``
 If specified, then the generated files will be grouped into a source folder using the :external:command:`source_group() <source_group>` command. The group will be named ``<groupName>``. If this argument is not specified, the generated files will not be grouped.


.. seealso ::

    Module :module:`OrangesGeneratePlatformHeader`
        This module provides platform- and compiler-specific macro definitions

    Module :module:`OrangesGenerateExportHeader`
        This module provides symbol visibility control utilities

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)
include (OrangesGenerateExportHeader)
include (OrangesGeneratePlatformHeader)
include (OrangesBuildTypeMacros)

#

function (oranges_generate_standard_headers target)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
        return ()
    endif ()

    set (options NO_AGGREGATE_HEADER)

    set (
        oneValueArgs
        BASE_NAME
        HEADER
        EXPORT_HEADER
        PLATFORM_HEADER
        INSTALL_COMPONENT
        REL_PATH
        FEATURE_TEST_LANGUAGE
        SOURCE_GROUP_NAME
        SCOPE)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_FEATURE_TEST_LANGUAGE)
        set (ORANGES_ARG_FEATURE_TEST_LANGUAGE "${PLAT_DEFAULT_TESTING_LANGUAGE}")
    endif ()

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${target}")
    endif ()

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_generated.h")
    endif ()

    if (NOT ORANGES_ARG_EXPORT_HEADER)
        set (ORANGES_ARG_EXPORT_HEADER "${ORANGES_ARG_BASE_NAME}_export.h")
    endif ()

    if (NOT ORANGES_ARG_PLATFORM_HEADER)
        set (ORANGES_ARG_PLATFORM_HEADER "${ORANGES_ARG_BASE_NAME}_platform.h")
    endif ()

    if (NOT ORANGES_ARG_SCOPE)
        get_target_property (target_type "${target}" TYPE)

        if ("${target_type}" STREQUAL INTERFACE_LIBRARY)
            set (ORANGES_ARG_SCOPE INTERFACE)
        elseif ("${target_type}" STREQUAL EXECUTABLE)
            set (ORANGES_ARG_SCOPE PUBLIC)
        else ()
            set (ORANGES_ARG_SCOPE PRIVATE)
        endif ()

        unset (target_type)
    endif ()

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component INSTALL_COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    if (ORANGES_ARG_REL_PATH)
        set (relative_path REL_PATH "${ORANGES_ARG_REL_PATH}")
    endif ()

    if (NOT ORANGES_ARG_NO_BUILD_TYPE_MACROS)
        oranges_add_build_type_macros ("${target}" BASE_NAME "${ORANGES_ARG_BASE_NAME}"
                                       SCOPE "${ORANGES_ARG_SCOPE}")
    endif ()

    oranges_generate_export_header (
        "${target}" BASE_NAME "${ORANGES_ARG_BASE_NAME}" HEADER "${ORANGES_ARG_EXPORT_HEADER}"
        SCOPE "${ORANGES_ARG_SCOPE}" ${install_component} ${relative_path})

    oranges_generate_platform_header (
        "${target}"
        BASE_NAME "${ORANGES_ARG_BASE_NAME}"
        HEADER "${ORANGES_ARG_PLATFORM_HEADER}"
        LANGUAGE "${ORANGES_ARG_FEATURE_TEST_LANGUAGE}"
        SCOPE "${ORANGES_ARG_SCOPE}" ${install_component} ${relative_path})

    if (NOT ORANGES_ARG_NO_AGGREGATE_HEADER)
        set (configured_file "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

        set (input_file "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/standard_header.h")

        configure_file ("${input_file}" "${configured_file}" @ONLY NEWLINE_STYLE UNIX)

        set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND CMAKE_CONFIGURE_DEPENDS
                                                            "${input_file}")

        set_source_files_properties ("${configured_file}" TARGET_DIRECTORY "${target}"
                                     PROPERTIES GENERATED ON)

        target_sources (
            "${target}"
            "${ORANGES_ARG_SCOPE}"
            $<BUILD_INTERFACE:${configured_file}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>
            )

        if (ORANGES_ARG_INSTALL_COMPONENT)
            set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
        else ()
            unset (install_component)
        endif ()

        install (FILES "${configured_file}"
                 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}"
                 ${install_component})

        target_include_directories (
            "${target}" "${ORANGES_ARG_SCOPE}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
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
