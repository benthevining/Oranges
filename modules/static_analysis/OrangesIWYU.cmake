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

OrangesIWYU
------------------

Provides a function to set up the include-what-you-use static analysis tool.


Configure include-what-you-use
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_enable_iwyu

    ::

        oranges_enable_iwyu (TARGET <target>
                            [EXTRA_ARGS <args...>]
                            [LANGS <C|CXX>...])

Configures include-what-you-use for the given ``<target>`` by manipulating
the target's ``<LANG>_INCLUDE_WHAT_YOU_USE`` properties.

Any specified ``EXTRA_ARGS`` will be passed to the include-what-you-use executable verbatim. If not
specified, the value of the :variable:`IWYU_EXTRA_ARGS` variable will be used.

Languages may be specified; valid values are ``C`` or ``CXX``. If no languages are specified, this function
will configure include-what-you-use for both valid languages.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: IWYU_PROGRAM

Path to the include-what-you-use executable, used by :command:`oranges_enable_iwyu`.
An environment variable with this name may also be set.

.. cmake:variable:: IWYU_EXTRA_ARGS

Space-separated arguments that will be passed verbatim to include-what-you-use in calls to
:command:`oranges_enable_iwyu` that do not explicitly override this option.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: IWYU_PROGRAM

Initializes the value of the :variable:`IWYU_PROGRAM` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

find_program (IWYU_PROGRAM NAMES include-what-you-use iwyu PATHS ENV IWYU_PROGRAM
              DOC "Path to the include-what-you-use executable")

set (IWYU_EXTRA_ARGS "--update_comments --cxx17ns"
     CACHE STRING "Space-separated arguments to be passed to include-what-you-use verbatim")

#

function (oranges_enable_iwyu)

    if (NOT IWYU_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable include-what-you-use, because include-what-you-use cannot be found. Set the IWYU_PROGRAM variable to its location."
            )
        return ()
    endif ()

    set (oneVal TARGET)
    set (multiVal EXTRA_ARGS LANGS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "${multiVal}" ${ARGN})

    if (NOT TARGET "${ORANGES_ARG_TARGET}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${ORANGES_ARG_TARGET}' does not exist!"
            )
    endif ()

    set (iwyu_cmd "${IWYU_PROGRAM}")

    #

    if (NOT ORANGES_ARG_EXTRA_ARGS)
        separate_arguments (ORANGES_ARG_EXTRA_ARGS UNIX_COMMAND "${IWYU_EXTRA_ARGS}")
    endif ()

    list (REMOVE_DUPLICATES ORANGES_ARG_EXTRA_ARGS)

    foreach (arg IN LISTS ORANGES_ARG_EXTRA_ARGS)
        list (APPEND iwyu_cmd -Xiwyu)
        list (APPEND iwyu_cmd "${arg}")
    endforeach ()

    #

    message (DEBUG "include-what-you-use command for target ${ORANGES_ARG_TARGET}: ${iwyu_cmd}")

    set (valid_languages C CXX)

    if (NOT ORANGES_ARG_LANGS)
        set (ORANGES_ARG_LANGS ${valid_languages})
    endif ()

    foreach (lang IN LISTS ORANGES_ARG_LANGS)

        string (TOUPPER "${lang}" lang)

        if (NOT "${lang}" IN_LIST valid_languages)
            message (WARNING "${CMAKE_CURRENT_FUNCTION} - language ${lang} is invalid!")
            continue ()
        endif ()

        set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES "${lang}_INCLUDE_WHAT_YOU_USE"
                                                                  "${iwyu_cmd}")

    endforeach ()

    message (VERBOSE "Enabled include-what-you-use for target ${ORANGES_ARG_TARGET}")

endfunction ()
