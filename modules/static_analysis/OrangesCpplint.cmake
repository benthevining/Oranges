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

OrangesCpplint
------------------

Provides a function to set up the cpplint static analysis tool.


Configure cpplint
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_enable_cpplint

    ::

        oranges_enable_cpplint (TARGET <target>
                               [IGNORE <checks...>]
                               [VERBOSITY <level>]
                               [EXTRA_ARGS <args...>]
                               [LANGS <C|CXX>...])

Configures cpplint for the given ``<target>`` by manipulating the target's ``<LANG>_CPPLINT`` properties.

Any specified ``EXTRA_ARGS`` will be passed to the cpplint executable verbatim. If not specified, the
value of the :variable:`CPPLINT_EXTRA_ARGS` variable will be used.

The ``IGNORE`` option is provided as a convenient way to specify lists of checks to ignore. If not specified,
the value of the :variable:`CPPLINT_IGNORE` variable will be used.

The ``VERBOSITY`` option may specify an integer verbosity level between 0 and 5 (inclusive). If not specified,
the value of the :variable:`CPPLINT_VERBOSITY` variable will be used.

Languages may be specified; valid values are ``C`` or ``CXX``. If no languages are specified, this function
will configure cpplint for both valid languages.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CPPLINT_PROGRAM

Path to the cpplint executable, used by :command:`oranges_enable_cpplint`.
An environment variable with this name may also be set.

.. cmake:variable:: CPPLINT_IGNORE

Space-separated list of cpplint checks to be ignored by default in calls to :command:`oranges_enable_cpplint` that do not
explicitly override this option.

.. cmake:variable:: CPPLINT_VERBOSITY

Default cpplint verbosity level to be used by calls to :command:`oranges_enable_cpplint` that do not explicitly
specify a verbosity level.

.. cmake:variable:: CPPLINT_EXTRA_ARGS

Space-separated arguments that will be passed to cpplint verbatim in calls to :command:`oranges_enable_cpplint`
that do not explicitly override this option.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CPPLINT_PROGRAM

Initializes the value of the :variable:`CPPLINT_PROGRAM` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

find_program (CPPLINT_PROGRAM cpplint PATHS ENV CPPLINT_PROGRAM
              DOC "Path to the cpplint executable")

set (CPPLINT_IGNORE
     "-whitespace -legal -build -runtime/references -readability/braces -readability/todo"
     CACHE STRING "Space-separated list of checks to be ignored by cpplint")

set (CPPLINT_VERBOSITY 0 CACHE STRING "Default cpplint verbosity (0 to 5)")

# cmake-format: off
set_property (CACHE CPPLINT_VERBOSITY
              PROPERTY STRINGS
              0 1 2 3 4 5)
# cmake-format: on

set (CPPLINT_EXTRA_ARGS "" CACHE STRING
                                 "Space-separated extra arguments to be passed to cpplint verbatim")

#

function (oranges_enable_cpplint)

    if (NOT CPPLINT_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable cpplint, because cpplint cannot be found. Set the CPPLINT_PROGRAM variable to its location."
            )
        return ()
    endif ()

    set (oneVal TARGET VERBOSITY)
    set (multiVal IGNORE EXTRA_ARGS LANGS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "${multiVal}" ${ARGN})

    if (NOT TARGET "${ORANGES_ARG_TARGET}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${ORANGES_ARG_TARGET}' does not exist!"
            )
    endif ()

    set (cpplint_cmd "${CPPLINT_PROGRAM}")

    #

    if (NOT ORANGES_ARG_VERBOSITY)
        set (ORANGES_ARG_VERBOSITY "${CPPLINT_VERBOSITY}")
    endif ()

    list (APPEND cpplint_cmd "--verbose=${ORANGES_ARG_VERBOSITY}")

    #

    if (NOT ORANGES_ARG_IGNORE)
        separate_arguments (ORANGES_ARG_IGNORE UNIX_COMMAND "${CPPLINT_IGNORE}")
    endif ()

    list (JOIN ORANGES_ARG_IGNORE "," ORANGES_ARG_IGNORE)

    set (cpplint_cmd "${cpplint_cmd};--filter=${ORANGES_ARG_IGNORE}")

    #

    if (NOT ORANGES_ARG_EXTRA_ARGS)
        separate_arguments (ORANGES_ARG_EXTRA_ARGS UNIX_COMMAND "${CPPLINT_EXTRA_ARGS}")
    endif ()

    if (ORANGES_ARG_EXTRA_ARGS)
        list (APPEND cpplint_cmd ${ORANGES_ARG_EXTRA_ARGS})
    endif ()

    #

    list (REMOVE_DUPLICATES cpplint_cmd)

    message (DEBUG "cpplint command for target ${ORANGES_ARG_TARGET}: ${cpplint_cmd}")

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

        set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES "${lang}_CPPLINT"
                                                                  "${cpplint_cmd}")

    endforeach ()

    set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES EXPORT_COMPILE_COMMANDS ON)

    message (VERBOSE "Enabled cpplint for target ${ORANGES_ARG_TARGET}")

endfunction ()
