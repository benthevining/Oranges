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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

find_package (SWIG COMPONENTS python)

include (UseSWIG)

#

function (oranges_add_swig_targets)

    set (oneValueArgs MODULE_NAME BINARY_DIR TYPE INPUT_LANGUAGE OUTPUT_VAR)
    set (multivalueArgs LANGUAGES SOURCES)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "${multivalueArgs}" ${ARGN})

    if (NOT ORANGES_ARG_BINARY_DIR)
        set (ORANGES_ARG_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/SWIG")
    endif ()

    if (NOT ORANGES_ARG_TYPE)
        set (ORANGES_ARG_TYPE SHARED)
    endif ()

    if (NOT ORANGES_ARG_INPUT_LANGUAGE)
        set (ORANGES_ARG_INPUT_LANGUAGE CXX)
    endif ()

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

        list (APPEND target_names "${lib_name}")

    endforeach ()

    if (ORANGES_ARG_OUTPUT_VAR)
        set (${ORANGES_ARG_OUTPUT_VAR} ${target_names} PARENT_SCOPE)
    endif ()

endfunction ()
