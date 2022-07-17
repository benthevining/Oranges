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

OrangesClangTidy
------------------

Provides a function to set up the clang-tidy static analysis tool.


Configure clang-tidy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_enable_clang_tidy

    ::

        oranges_enable_clang_tidy (TARGET <target>
                                  [CONFIG_FILE <file>]
                                  [EXTRA_ARGS <args...>]
                                  [LANGS <C|CXX|OBJC|OBJCXX>...])

Configures clang-tidy for the given ``<target>`` by manipulating the target's ``<LANG>_CLANG_TIDY`` properties.

A custom configuration file may optionally be specified; if a relative path is given, it will be evaluated relative to
the value of ``CMAKE_CURRENT_LIST_DIR`` when this function is called. If this argument is not specified, the value of
the :variable:`CLANGTIDY_CONFIG_FILE` variable will be used. Providing this argument is equivalent to passing
``EXTRA_ARGS --config-file=<file>``.

Any specified ``EXTRA_ARGS`` will be passed to the clang-tidy executable verbatim. If not specified, the value of the
:variable:`CLANGTIDY_EXTRA_ARGS` variable will be used.

Languages may be specified; valid values are ``C``, ``CXX``, ``OBJC``, or ``OBJCXX``. If no languages are specified, this
function will configure clang-tidy for all four valid languages.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CLANGTIDY_PROGRAM

Path to the clang-tidy executable, used by :command:`oranges_enable_clang_tidy`.
An environment variable with this name may also be set.

.. cmake:variable:: CLANGTIDY_CONFIG_FILE

This variable may be set to a ``.clang-tidy`` file that will be used for all calls to :command:`oranges_enable_clang_tidy`
that do not explicitly provide their own config file.

.. cmake:variable:: CLANGTIDY_EXTRA_ARGS

This variable may be set to a list of space-separated arguments that will be passed to clang-tidy verbatim for the
:command:`oranges_enable_clang_tidy` command.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CLANGTIDY_PROGRAM

Initializes the value of the :variable:`CLANGTIDY_PROGRAM` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

find_program (CLANGTIDY_PROGRAM clang-tidy PATHS ENV CLANGTIDY_PROGRAM
              DOC "Path to the clang-tidy executable")

set (CLANGTIDY_CONFIG_FILE "" CACHE FILEPATH "Default .clang-tidy file to be used")

set (CLANGTIDY_EXTRA_ARGS ""
     CACHE STRING "Space-separated extra arguments to be passed to clang-tidy verbatim")

#

function (oranges_enable_clang_tidy)

    if (NOT CLANGTIDY_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable clang-tidy, because clang-tidy cannot be found. Set the CLANGTIDY_PROGRAM variable to its location."
            )
        return ()
    endif ()

    set (oneVal TARGET CONFIG_FILE)
    set (multiVal LANGS EXTRA_ARGS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "${multiVal}" ${ARGN})

    if (NOT TARGET "${ORANGES_ARG_TARGET}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${ORANGES_ARG_TARGET}' does not exist!"
            )
    endif ()

    set (clangtidy_cmd "${CLANGTIDY_PROGRAM}")

    #

    if (NOT ORANGES_ARG_CONFIG_FILE)
        set (ORANGES_ARG_CONFIG_FILE "${CLANGTIDY_CONFIG_FILE}")
    endif ()

    if (ORANGES_ARG_CONFIG_FILE)
        if (NOT IS_ABSOLUTE "${ORANGES_ARG_CONFIG_FILE}")
            set (ORANGES_ARG_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/${ORANGES_ARG_CONFIG_FILE}")
        endif ()

        list (APPEND clangtidy_cmd "--config-file=${ORANGES_ARG_CONFIG_FILE}")
    endif ()

    #

    if (NOT ORANGES_ARG_EXTRA_ARGS)
        separate_arguments (ORANGES_ARG_EXTRA_ARGS UNIX_COMMAND "${CLANGTIDY_EXTRA_ARGS}")
    endif ()

    if (ORANGES_ARG_EXTRA_ARGS)
        list (APPEND clangtidy_cmd ${ORANGES_ARG_EXTRA_ARGS})
    endif ()

    #

    list (REMOVE_DUPLICATES clangtidy_cmd)

    message (DEBUG "clang-tidy command for target ${ORANGES_ARG_TARGET}: ${clangtidy_cmd}")

    set (valid_languages C CXX OBJC OBJCXX)

    if (NOT ORANGES_ARG_LANGS)
        set (ORANGES_ARG_LANGS ${valid_languages})
    endif ()

    foreach (lang IN LISTS ORANGES_ARG_LANGS)

        string (TOUPPER "${lang}" lang)

        if (NOT "${lang}" IN_LIST valid_languages)
            message (WARNING "${CMAKE_CURRENT_FUNCTION} - language ${lang} is invalid!")
            continue ()
        endif ()

        set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES "${lang}_CLANG_TIDY"
                                                                  "${clangtidy_cmd}")

    endforeach ()

    set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES EXPORT_COMPILE_COMMANDS ON)

    message (VERBOSE "Enabled clang-tidy for target ${ORANGES_ARG_TARGET}")

endfunction ()
