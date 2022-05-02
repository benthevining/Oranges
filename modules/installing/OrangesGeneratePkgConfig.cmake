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

OrangesGeneratePkgConfig
-------------------------

This module provides the function :command:`oranges_create_pkgconfig_file()`.

.. command:: oranges_create_pkgconfig_file

  ::

    oranges_create_pkgconfig_file (TARGET <targetName>
                                  [OUTPUT_DIR <outputDir>]
                                  [NAME <packageName>]
                                  [INCLUDE_REL_PATH <basePath>]
                                  [DESCRIPTION <projectDescription>]
                                  [URL <projectURL>]
                                  [VERSION <projectVersion>]
                                  [NO_INSTALL]|[INSTALL_DEST <installDestination>] [INSTALL_COMPONENT <componentName>]
                                  [REQUIRES <requiredPackages...>])

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)
include (GNUInstallDirs)

#

function (oranges_create_pkgconfig_file)

    oranges_add_function_message_context ()

    set (options NO_INSTALL)
    set (
        oneValueArgs
        TARGET
        OUTPUT_DIR
        NAME
        INCLUDE_REL_PATH
        DESCRIPTION
        URL
        VERSION
        INSTALL_DEST
        INSTALL_COMPONENT)
    set (multiValueArgs REQUIRES)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG TARGET)
    lemons_check_for_unparsed_args (ORANGES_ARG)
    oranges_assert_target_argument_is_target (ORANGES_ARG)

    if (ORANGES_ARG_NO_INSTALL AND ORANGES_ARG_INSTALL_DEST)
        message (
            "NO_INSTALL and INSTALL_DEST cannot both be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
            )
    endif ()

    if (NOT ORANGES_ARG_OUTPUT_DIR)
        set (ORANGES_ARG_OUTPUT_DIR "${PROJECT_BINARY_DIR}/pkgconfig")
    endif ()

    if (NOT ORANGES_ARG_NAME)
        set (ORANGES_ARG_NAME "${ORANGES_ARG_TARGET}")
    endif ()

    if (NOT ORANGES_ARG_INCLUDE_REL_PATH)
        set (ORANGES_ARG_INCLUDE_REL_PATH "${ORANGES_ARG_NAME}")
    endif ()

    if (NOT ORANGES_ARG_DESCRIPTION)
        set (ORANGES_ARG_DESCRIPTION "${PROJECT_DESCRIPTION}")
    endif ()

    if (NOT ORANGES_ARG_URL)
        set (ORANGES_ARG_URL "${PROJECT_HOMEPAGE_URL}")
    endif ()

    if (NOT ORANGES_ARG_VERSION)
        set (ORANGES_ARG_VERSION "${PROJECT_VERSION}")
    endif ()

    if (NOT ORANGES_ARG_NO_INSTALL)
        set (ORANGES_ARG_NO_INSTALL FALSE)
    endif ()

    if (NOT ORANGES_ARG_INSTALL_DEST)
        set (ORANGES_ARG_INSTALL_DEST "${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig")
    endif ()

    list (JOIN ORANGES_ARG_REQUIRES " " ORANGES_ARG_REQUIRES)

    set (pc_file_configured "${ORANGES_ARG_OUTPUT_DIR}/${ORANGES_ARG_NAME}.pc.in")

    set (pc_input "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/config.pc")

    configure_file ("${pc_input}" "${pc_file_configured}" @ONLY NEWLINE_STYLE UNIX ESCAPE_QUOTES)

    set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                                                                 "${pc_input}")

    set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                 "${pc_file_configured}")

    set (pc_file_output "${ORANGES_ARG_OUTPUT_DIR}/${ORANGES_ARG_NAME}-$<CONFIG>.pc")

    file (GENERATE OUTPUT "${pc_file_output}" INPUT "${pc_file_configured}"
          TARGET "${ORANGES_ARG_TARGET}" NEWLINE_STYLE UNIX)

    if (NOT ORANGES_ARG_NO_INSTALL)
        if (ORANGES_ARG_INSTALL_COMPONENT)
            set (component_flag COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
        endif ()

        install (FILES "${pc_file_output}" DESTINATION "${ORANGES_ARG_INSTALL_DEST}"
                 ${component_flag})
    endif ()

endfunction ()
