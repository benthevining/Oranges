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

OrangesCcache
-------------------------

Provides a function to set up the ccache compiler cache.

.. command:: oranges_enable_ccache

    ::

        oranges_enable_ccache (TARGET <target>
                              [OPTIONS <args...>])

Enables the ccache compiler cache for the specified ``<target>``.

Any specified ``OPTIONS`` are passed to the ccache executable verbatim. If not specified,
the value of the :variable:`CCACHE_OPTIONS` variable is used.

If the :variable:`CCACHE_DISABLE` option is set to ``ON``, calling this function does nothing.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CCACHE_PROGRAM

Path to the ccache executable used for :command:`oranges_enable_ccache`.

.. cmake:variable:: CCACHE_DISABLE

When ``ON``, ccache is disabled for the entire build and calling :command:`oranges_enable_ccache`
does nothing. Defaults to ``OFF``.

.. cmake:variable:: CCACHE_OPTIONS

A space-separated list of command line flags to pass to ccache. Used for :command:`oranges_enable_ccache`
when custom options are not explicitly specified.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

enable_language (CXX)
enable_language (C)

find_program (CCACHE_PROGRAM ccache PATHS ENV CCACHE_PROGRAM DOC "Path to the ccache executable")

option (CCACHE_DISABLE "When ON, ccache is disabled for the entire build" OFF)

set (
    CCACHE_OPTIONS
    "CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=6 CCACHE_MAXSIZE=800M CCACHE_BASEDIR=${CMAKE_SOURCE_DIR} CCACHE_DIR=${CMAKE_SOURCE_DIR}/Cache/ccache/cache"
    CACHE STRING "Space-separated command line options that will be passed to ccache")

#

function (oranges_enable_ccache)

    if (NOT CCACHE_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable ccache, because ccache cannot be found. Set the CCACHE_PROGRAM variable to its location."
            )
        return ()
    endif ()

    if (CCACHE_DISABLE)
        message (VERBOSE
                 "${CMAKE_CURRENT_FUNCTION} - disabling ccache because CCACHE_DISABLE option is ON")
        return ()
    endif ()

    cmake_parse_arguments (ORANGES_ARG "" "TARGET" "OPTIONS" ${ARGN})

    if (NOT TARGET "${ORANGES_ARG_TARGET}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${ORANGES_ARG_TARGET}' does not exist!"
            )
    endif ()

    #

    if (NOT ORANGES_ARG_OPTIONS)
        separate_arguments (ORANGES_ARG_OPTIONS UNIX_COMMAND "${CCACHE_OPTIONS}")
    endif ()

    list (REMOVE_DUPLICATES ORANGES_ARG_OPTIONS)

    if (ORANGES_ARG_OPTIONS)
        list (JOIN ORANGES_ARG_OPTIONS "\n export " CCACHE_EXPORTS)
    else ()
        set (CCACHE_EXPORTS "")
    endif ()

    #

    foreach (language IN ITEMS c cxx)

        string (TOUPPER "${language}" lang_upper)

        set (CCACHE_COMPILER_BEING_CONFIGURED "${CMAKE_${lang_upper}_COMPILER}")

        set (configured_script
             "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_TARGET}/launch-${language}")

        configure_file ("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/launcher.in"
                        "${configured_script}" @ONLY NEWLINE_STYLE UNIX)

        set (${language}_script "${configured_script}")

    endforeach ()

    # for some reason, this only works if done in a separate process

    set (chmod_script "${CMAKE_CURRENT_BINARY_DIR}/chmod.cmake")

    file (
        WRITE "${chmod_script}"
        "file (CHMOD
               \"${c_script}\"
               \"${cxx_script}\"
               PERMISSIONS WORLD_EXECUTE WORLD_READ)")

    execute_process (COMMAND "${CMAKE_COMMAND}" -P "${chmod_script}")

    if (XCODE)
        set_target_properties (
            "${ORANGES_ARG_TARGET}"
            PROPERTIES XCODE_ATTRIBUTE_CC "${c_script}" XCODE_ATTRIBUTE_CXX "${cxx_script}"
                       XCODE_ATTRIBUTE_LD "${c_script}" XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}")
    else ()
        set_target_properties (
            "${ORANGES_ARG_TARGET}" PROPERTIES C_COMPILER_LAUNCHER "${c_script}"
                                               CXX_COMPILER_LAUNCHER "${cxx_script}")
    endif ()

endfunction ()