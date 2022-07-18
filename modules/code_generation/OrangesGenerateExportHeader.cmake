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

This module is a thin wrapper around CMake's :external:command:`generate_export_header() <generate_export_header>`, and adds the :command:`oranges_generate_export_header() <generate_export_header>` command.

.. command:: oranges_generate_export_header

  ::

    oranges_generate_export_header (<targetName>
                                   [BASE_NAME <baseName>]
                                   [HEADER <exportHeaderName>]
                                   [SCOPE <PUBLIC|PRIVATE|INTERFACE>]
                                   [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>])

Generates a header file containing symbol export macros, and adds it to the specified target.

Options:

``BASE_NAME``
 Prefix to use for all macros in the generated header file. Defaults to ``<targetName>``.

``SCOPE``
 The visibility with which the generated header will be added to the target. Defaults to ``INTERFACE`` for interface library targets, ``PRIVATE`` for executables, and ``PUBLIC`` for all other target types.

``INSTALL_COMPONENT``
 Name of an install component to add the generated header to. The install component will not be created by this command.

``REL_PATH``
 A path below ``CMAKE_INSTALL_INCLUDEDIR`` where the generated header will be installed to. Defaults to ``<targetName>``.


.. seealso ::

    Module :external:module:`GenerateExportHeader`
        OrangesGenerateExportHeader is a thin wrapper around this module shipped by CMake

    Module :module:`OrangesGenerateStandardHeaders`
        An aggregate module that includes this one

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

#

function (oranges_generate_export_header target)

    # NB. this include must be in this function's scope, to prevent bugs with this module's
    # variables!
    include (GenerateExportHeader)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
        return ()
    endif ()

    set (oneValueArgs BASE_NAME HEADER REL_PATH INSTALL_COMPONENT SCOPE)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    set_target_properties ("${target}" PROPERTIES CXX_VISIBILITY_PRESET hidden
                                                  VISIBILITY_INLINES_HIDDEN TRUE)

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${target}")
    endif ()

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_export.h")
    endif ()

    get_target_property (target_type "${target}" TYPE)

    if (NOT ORANGES_ARG_SCOPE)
        if ("${target_type}" STREQUAL INTERFACE_LIBRARY)
            set (ORANGES_ARG_SCOPE INTERFACE)
        elseif ("${target_type}" STREQUAL EXECUTABLE)
            set (ORANGES_ARG_SCOPE PUBLIC)
        else ()
            set (ORANGES_ARG_SCOPE PRIVATE)
        endif ()
    endif ()

    unset (target_type)

    generate_export_header ("${target}" BASE_NAME "${ORANGES_ARG_BASE_NAME}" EXPORT_FILE_NAME
                            "${ORANGES_ARG_HEADER}" ${no_build_deprecated})

    if (NOT ORANGES_ARG_REL_PATH)
        set (ORANGES_ARG_REL_PATH "${target}")
    endif ()

    set (generated_file "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

    set_source_files_properties ("${generated_file}" TARGET_DIRECTORY "${target}"
                                 PROPERTIES GENERATED ON)

    target_sources (
        "${target}"
        "${ORANGES_ARG_SCOPE}"
        "$<BUILD_INTERFACE:${generated_file}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>"
        )

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    install (FILES "${generated_file}"
             DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}" ${install_component})

    target_include_directories (
        "${target}" "${ORANGES_ARG_SCOPE}" "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>")

    string (TOUPPER "${ORANGES_ARG_BASE_NAME}" upperBaseName)

    target_compile_definitions (
        "${target}"
        "${ORANGES_ARG_SCOPE}"
        "$<$<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,STATIC_LIBRARY>:${upperBaseName}_STATIC_DEFINE=1>"
        )

endfunction ()
