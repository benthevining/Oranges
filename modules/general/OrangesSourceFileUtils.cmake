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

OrangesSourceFileUtils
-------------------------

Utility function for adding source files to a target, and generating install rules for any header files.

.. command:: oranges_add_source_files

  ::

    oranges_add_source_files (TARGET <target>
                              DIRECTORY_NAME <directory>
                              FILES <filenames...>
                             [PUBLIC_HEADERS <headers...>]
                             [INSTALL_DIR <installBaseDir>]
                             [INSTALL_COMPONENT <component>])

This function adds the source files to the given target, and adds rules for any headers to be installed to ``<installBaseDir>/<directory>``.
Headers are identified by file extensions ``.h``, ``.hpp``, or ``.hxx``.

``INSTALL_DIR`` defaults to :variable:`CMAKE_INSTALL_INCLUDEDIR`.

The variable ``<directory>_files`` will be set in the scope of the caller as a list of filenames, each in the form ``<directory>/<filename>``.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (GNUInstallDirs)
include (OrangesFunctionArgumentHelpers)

#

function (oranges_add_source_files)

    set (oneValueArgs DIRECTORY_NAME TARGET INSTALL_COMPONENT INSTALL_DIR)
    set (multiValueArgs FILES PUBLIC_HEADERS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    oranges_assert_target_argument_is_target (ORANGES_ARG)
    lemons_require_function_arguments (ORANGES_ARG DIRECTORY_NAME FILES)

    #

    macro (__oranges_add_header_set __headers __scope)
        foreach (__filename IN ITEMS ${__headers})
            if (NOT IS_ABSOLUTE "${__filename}")
                set (__filename "${CMAKE_CURRENT_LIST_DIR}/${__filename}")
            endif ()

            target_sources ("${ORANGES_ARG_TARGET}" "${__scope}" "$<BUILD_INTERFACE:${__filename}>")
        endforeach ()
    endmacro ()

    __oranges_add_header_set ("${ORANGES_ARG_FILES}" PRIVATE)
    __oranges_add_header_set ("${ORANGES_ARG_PUBLIC_HEADERS}" PUBLIC)

    #

    if (NOT ORANGES_ARG_INSTALL_DIR)
        set (ORANGES_ARG_INSTALL_DIR "${CMAKE_INSTALL_INCLUDEDIR}")
    endif ()

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    #

    function (__oranges_make_abs_paths_relative __listVar)
        foreach (__filename IN ITEMS ${${__listVar}})
            cmake_path (GET __filename FILENAME __filename)
            list (APPEND __temp_files "${__filename}")
        endforeach ()

        set ("${__listVar}" ${__temp_files} PARENT_SCOPE)
    endfunction ()

    #

    function (__oranges_install_header_set __headers __scope)

        set (__headers_list ${__headers})

        list (FILTER __headers_list INCLUDE REGEX "\\.\\h|\\.\\hpp|\\.\\hxx")

        __oranges_make_abs_paths_relative (__headers_list)

        set (__dirpath "${ORANGES_ARG_INSTALL_DIR}/${ORANGES_ARG_DIRECTORY_NAME}")

        install (FILES ${__headers_list} DESTINATION "${__dirpath}" ${install_component})

        foreach (__header IN LISTS __headers_list)
            target_sources ("${ORANGES_ARG_TARGET}" "${__scope}"
                                                    "$<INSTALL_INTERFACE:${__dirpath}/${__header}>")
        endforeach ()

        unset (__headers_list)
    endfunction ()

    __oranges_install_header_set ("${ORANGES_ARG_FILES}" PRIVATE)
    __oranges_install_header_set ("${ORANGES_ARG_PUBLIC_HEADERS}" PUBLIC)

    #

    set (all_files ${ORANGES_ARG_FILES} ${ORANGES_ARG_PUBLIC_HEADERS})

    __oranges_make_abs_paths_relative (all_files)

    list (TRANSFORM all_files PREPEND "${ORANGES_ARG_DIRECTORY_NAME}/")

    set (${ORANGES_ARG_DIRECTORY_NAME}_files ${all_files} PARENT_SCOPE)

endfunction ()
