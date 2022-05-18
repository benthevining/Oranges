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

OrangesSWIG
-------------------------

This module provides the command :command:`oranges_add_swig_targets() <oranges_add_swig_targets>`.

If the SWIG package hasn't already been found, including this module will call ``find_package (SWIG)``.

.. command:: oranges_add_swig_targets

  ::

    oranges_add_swig_targets (MODULE_NAME <moduleName>
                              LANGUAGES <languages...>
                              SOURCES <sources...>
                             [AGGREGATE_TARGET <targetName>]|[NO_AGGREGATE_TARGET]
                             [BINARY_DIR <binDir>]
                             [TYPE <type>]
                             [INPUT_LANGUAGE <language>]
                             [OUTPUT_VAR <variableName>])

Creates SWIG libraries in each of the output languages listed in ``LANGUAGES``. The target for each output language will be named ``<moduleName>_<lang>``.

This is basically a wrapper around CMake's :command:`swig_add_library() <swig_add_library>`, with the convenience of being able to create targets for multiple target languages in one function call.

``AGGREGATE_TARGET`` is the name of an interface target that links to all the generated SWIG targets. It defaults to ``<moduleName>_SWIG``.
If the ``NO_AGGREGATE_TARGET`` option is given, then no aggregate target will be created.

``TYPE`` defines the type of the libraries to be created. Defaults to ``SHARED``.

``INPUT_LANGUAGE`` is used to set the linker language for the generated SWIG targets; defaults to ``CXX``.

If ``OUTPUT_VAR`` is specified, a variable with that name will be set in the calling scope to a list containing all the names of the generated SWIG targets (excluding the aggregate target, if any).

.. seealso::

    Module :module:`UseSWIG`
        CMake's built-in SWIG support.

    Module :module:`FindSWIG`
        CMake's built-in find module for SWIG.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (NOT SWIG_FOUND)
    find_package (SWIG COMPONENTS python)
endif ()

include (UseSWIG)
include (OrangesFunctionArgumentHelpers)

#

function (oranges_add_swig_targets)

    if (NOT SWIG_FOUND)
        message (
            WARNING
                "${CMAKE_CURRENT_FUNCTION} - SWIG could not be found, SWIG targets cannot be added."
            )
        return ()
    endif ()

    set (options NO_AGGREGATE_TARGET)
    set (oneValueArgs MODULE_NAME BINARY_DIR TYPE INPUT_LANGUAGE OUTPUT_VAR AGGREGATE_TARGET)
    set (multivalueArgs LANGUAGES SOURCES)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multivalueArgs}" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG MODULE_NAME LANGUAGES SOURCES)

    if (ORANGES_ARG_NO_AGGREGATE_TARGET AND ORANGES_ARG_AGGREGATE_TARGET)
        message (
            AUTHOR_WARNING
                "${CMAKE_CURRENT_FUNCTION} - NO_AGGREGATE_TARGET and AGGREGATE_TARGET cannot both be specified!"
            )
    endif ()

    if (NOT ORANGES_ARG_BINARY_DIR)
        set (ORANGES_ARG_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/SWIG")
    endif ()

    if (NOT ORANGES_ARG_TYPE)
        set (ORANGES_ARG_TYPE SHARED)
    endif ()

    if (NOT ORANGES_ARG_INPUT_LANGUAGE)
        set (ORANGES_ARG_INPUT_LANGUAGE CXX)
    endif ()

    if (NOT ORANGES_ARG_NO_AGGREGATE_TARGET)

        if (NOT ORANGES_ARG_AGGREGATE_TARGET)
            set (ORANGES_ARG_AGGREGATE_TARGET "${ORANGES_ARG_MODULE_NAME}_SWIG")
        endif ()

        add_library ("${ORANGES_ARG_AGGREGATE_TARGET}" INTERFACE)
    endif ()

    unset (target_names)

    foreach (lang IN LISTS ORANGES_ARG_LANGUAGES)

        string (TOUPPER "${lang}" lang)

        set (lib_name "${ORANGES_ARG_MODULE_NAME}_${lang}")

        string (TOLOWER "${lang}" lang)

        set (bin_dir "${ORANGES_ARG_BINARY_DIR}/${lang}")

        swig_add_library (
            "${lib_name}" TYPE "${ORANGES_ARG_TYPE}" LANGUAGE "${lang}" OUTPUT_DIR "${bin_dir}"
                                                                        OUTFILE_DIR "${bin_dir}"
            SOURCES ${ORANGES_ARG_SOURCES})

        set_target_properties (
            "${lib_name}" PROPERTIES SWIG_MODULE_NAME "${ORANGES_ARG_MODULE_NAME}"
                                     LINKER_LANGUAGE "${ORANGES_ARG_INPUT_LANGUAGE}")

        if (TARGET "${ORANGES_ARG_AGGREGATE_TARGET}")
            target_link_libraries ("${ORANGES_ARG_AGGREGATE_TARGET}" INTERFACE "${lib_name}")
        endif ()

        list (APPEND target_names "${lib_name}")

    endforeach ()

    if (ORANGES_ARG_OUTPUT_VAR)
        set (${ORANGES_ARG_OUTPUT_VAR} ${target_names} PARENT_SCOPE)
    endif ()

endfunction ()
