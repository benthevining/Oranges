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

        oranges_enable_cpplint (<target>
                               [IGNORE <checks...>]
                               [VERBOSITY <level>]
                               [EXTRA_ARGS <args...>]
                               [LANGS <C|CXX>...])

Configures cpplint for the given ``<target>`` by manipulating the target's ``<LANG>_CPPLINT`` properties.

If the :variable:`CPPLINT_OFF` variable is set to ``ON``, this function does nothing.

Options:

``IGNORE``
 A list of cpplint checks to ignore for this target. Each one may optionally begin with a '-' character, though
 this is not required. f not specified, the value of the :variable:`CPPLINT_IGNORE` variable will be used.

``VERBOSITY``
 An integer verbosity level between 0 and 5 (inclusive). If not specified, the value of the
 :variable:`CPPLINT_VERBOSITY` variable will be used.

``EXTRA_ARGS``
 Extra arguments to pass to cpplint verbatim. If not specified, the value of the :variable:`CPPLINT_EXTRA_ARGS`
 variable will be used.

``LANGS``
 Languages for which to enable cpplint. Valid values are ``C`` or ``CXX``. If no languages are specified, this function
 will configure cpplint for both valid languages.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CPPLINT_PROGRAM

Path to the cpplint executable, used by :command:`oranges_enable_cpplint`.
An environment variable with this name may also be set.


.. cmake:variable:: CPPLINT_IGNORE

Space-separated list of cpplint checks to be ignored by default in calls to :command:`oranges_enable_cpplint` that do not
explicitly override this option. The environment variable with this name, if set, will initialize this variable; otherwise,
a default set of checks will be ignored.


.. cmake:variable:: CPPLINT_VERBOSITY

Default cpplint verbosity level to be used by calls to :command:`oranges_enable_cpplint` that do not explicitly
specify a verbosity level. The environment variable with this name, if set, will initialize this variable; otherwise, this
variable defaults to ``0``.


.. cmake:variable:: CPPLINT_EXTRA_ARGS

Space-separated arguments that will be passed to cpplint verbatim in calls to :command:`oranges_enable_cpplint`
that do not explicitly override this option. The environment variable with this name, if set, will initialize this
cache variable.


.. cmake:variable:: CPPLINT_OFF

When this variable is set to ``ON``, calls to :command:`oranges_enable_cpplint` do nothing. The environment variable with
this name, if set, will initialize this variable; otherwise, this variable defaults to ``OFF``.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CPPLINT_PROGRAM

Initializes the value of the :variable:`CPPLINT_PROGRAM` variable.


.. cmake:envvar:: CPPLINT_IGNORE

Initializes the :variable:`CPPLINT_IGNORE` variable.


.. cmake:envvar:: CPPLINT_VERBOSITY

Initializes the :variable:`CPPLINT_VERBOSITY` variable.


.. cmake:envvar:: CPPLINT_EXTRA_ARGS

Initializes the :variable:`CPPLINT_EXTRA_ARGS` variable.


.. cmake:envvar:: CPPLINT_OFF

Initializes the :variable:`CPPLINT_OFF` variable.


.. seealso ::

    Module :module:`OrangesClangTidy`
        Module for clang-tidy

    Module :module:`OrangesCppcheck`
        Module for cppcheck

    Module :module:`OrangesIWYU`
        Module for include-what-you-use

    Module :module:`OrangesStaticAnalysis`
        Aggregate module for enabling all static analysis tools

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

find_program (CPPLINT_PROGRAM cpplint PATHS ENV CPPLINT_PROGRAM
              DOC "Path to the cpplint executable")

if (DEFINED ENV{CPPLINT_IGNORE})
    set (cpplint_ignore_init "$ENV{CPPLINT_IGNORE}")
else ()
    set (cpplint_ignore_init
         "whitespace legal build runtime/references readability/braces readability/todo")
endif ()

set (CPPLINT_IGNORE "${cpplint_ignore_init}"
     CACHE STRING "Space-separated list of checks to be ignored by cpplint")

unset (cpplint_ignore_init)

if (DEFINED ENV{CPPLINT_VERBOSITY})
    set (cpplint_verb_init "$ENV{CPPLINT_VERBOSITY}")
else ()
    set (cpplint_verb_init 0)
endif ()

set (CPPLINT_VERBOSITY "${cpplint_verb_init}" CACHE STRING "Default cpplint verbosity (0 to 5)")

unset (cpplint_verb_init)

# cmake-format: off
set_property (CACHE CPPLINT_VERBOSITY
              PROPERTY STRINGS
              0 1 2 3 4 5)
# cmake-format: on

set (CPPLINT_EXTRA_ARGS "$ENV{CPPLINT_EXTRA_ARGS}"
     CACHE STRING "Space-separated extra arguments to be passed to cpplint verbatim")

if (DEFINED ENV{CPPLINT_OFF})
    set (cpplint_off_init "$ENV{CPPLINT_OFF}")
else ()
    set (cpplint_off_init OFF)
endif ()

option (CPPLINT_OFF "Disable cpplint for the entire build" "${cpplint_off_init}")

unset (cpplint_off_init)

#

function (oranges_enable_cpplint target)

    if (NOT CPPLINT_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable cpplint, because cpplint cannot be found. Set the CPPLINT_PROGRAM variable to its location."
            )
        return ()
    endif ()

    if (CPPLINT_OFF)
        message (VERBOSE
                 "${CMAKE_CURRENT_FUNCTION} - not enabling cpplint, because CPPLINT_OFF is ON.")
        return ()
    endif ()

    set (oneVal VERBOSITY)
    set (multiVal IGNORE EXTRA_ARGS LANGS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "${multiVal}" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${target}' does not exist!")
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

    set (cpplint_ignores "")

    foreach (ignore IN LISTS ORANGES_ARG_IGNORE)
        # check if the string starts with '-'
        string (SUBSTRING "${ignore}" 0 1 first_char)

        if ("${first_char}" STREQUAL "-")
            list (APPEND cpplint_ignores "${ignore}")
        else ()
            list (APPEND cpplint_ignores "-${ignore}")
        endif ()
    endforeach ()

    if (cpplint_ignores)
        list (REMOVE_DUPLICATES cpplint_ignores)
        list (JOIN cpplint_ignores "," cpplint_ignores)

        set (cpplint_cmd "${cpplint_cmd};--filter=${cpplint_ignores}")
    endif ()

    #

    if (NOT ORANGES_ARG_EXTRA_ARGS)
        separate_arguments (ORANGES_ARG_EXTRA_ARGS UNIX_COMMAND "${CPPLINT_EXTRA_ARGS}")
    endif ()

    if (ORANGES_ARG_EXTRA_ARGS)
        list (REMOVE_DUPLICATES ORANGES_ARG_EXTRA_ARGS)
        list (APPEND cpplint_cmd ${ORANGES_ARG_EXTRA_ARGS})
    endif ()

    #

    list (REMOVE_DUPLICATES cpplint_cmd)

    message (DEBUG "cpplint command for target ${target}: ${cpplint_cmd}")

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

        set_target_properties ("${target}" PROPERTIES "${lang}_CPPLINT" "${cpplint_cmd}")

    endforeach ()

    set_target_properties ("${target}" PROPERTIES EXPORT_COMPILE_COMMANDS ON)

    message (VERBOSE "Enabled cpplint for target ${target}")

endfunction ()
