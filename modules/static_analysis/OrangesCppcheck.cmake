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

OrangesCppcheck
------------------

Provides a function to set up the cppcheck static analysis tool.


Configure cppcheck
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_enable_cppcheck

    ::

        oranges_enable_cppcheck (<target>
                                [ENABLE <checks...>]
                                [DISABLE <checks...>]
                                [EXTRA_ARGS <args...>]
                                [LANGS <C|CXX>...])

Configures cppcheck for the given ``<target>`` by manipulating the target's ``<LANG>_CPPCHECK`` properties.

If the :variable:`CPPCHECK_OFF` variable is set to ``ON``, this function does nothing.

Options:

``ENABLE``
 A list of checks to enable for this target. If not specified, the value of the :variable:`CPPCHECK_ENABLE`
 variable will be used.

``DISABLE``
 A list of checks to disable for this target. If not specified, the value of the :variable:`CPPCHECK_DISABLE`
 variable will be used.

``EXTRA_ARGS``
 A list of extra arguments to pass to cppcheck verbatim. If not specified, the value of the
 :variable:`CPPCHECK_EXTRA_ARGS` variable will be used.

``LANGS``
 Languages for which to enable cppcheck. Valid values are ``C`` or ``CXX``. If no languages are specified, this
 function will configure cppcheck for both valid languages.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CPPCHECK_PROGRAM

Path to the cppcheck executable, used by :command:`oranges_enable_cppcheck`.
An environment variable with this name may also be set.


.. cmake:variable:: CPPCHECK_ENABLE

A space-separated list of default cppcheck checks to be enabled with calls to :command:`oranges_enable_cppcheck` that do not
explicitly list their own desired checks.


.. cmake:variable:: CPPCHECK_DISABLE

A space-separated list of default cppchecks checks to be disabled with calls to :command:`oranges_enable_cppcheck` that do not
explicitly list their own desired disabled checks.


.. cmake:variable:: CPPCHECK_EXTRA_ARGS

A list of space-separated arguments that will be passed to cppcheck verbatim in calls to :command:`oranges_enable_cppcheck`.


.. cmake:variable:: CPPCHECK_OFF

When this variable is set to ``ON``, calls to :command:`oranges_enable_cppcheck` do nothing. Defaults to ``OFF``.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CPPCHECK_PROGRAM

Initializes the value of the :variable:`CPPCHECK_PROGRAM` variable.


.. seealso ::

    Module :module:`OrangesClangTidy`
        Module for clang-tidy

    Module :module:`OrangesCpplint`
        Module for cpplint

    Module :module:`OrangesIWYU`
        Module for include-what-you-use

    Module :module:`OrangesStaticAnalysis`
        Aggregate module for enabling all static analysis tools

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

find_program (CPPCHECK_PROGRAM cppcheck PATHS ENV CPPCHECK_PROGRAM
              DOC "Path to the cppcheck executable")

set (CPPCHECK_ENABLE "warning style performance portability"
     CACHE STRING "Space-separated list of cppcheck checks to enable")

set (
    CPPCHECK_DISABLE
    "unmatchedSuppression missingIncludeSystem unusedStructMember unreadVariable preprocessorErrorDirective unknownMacro"
    CACHE STRING "Space-separated list of cppcheck checks to disable")

set (CPPCHECK_EXTRA_ARGS "--inline-suppr"
     CACHE STRING "Space-separated arguments that will be passed to cppcheck verbatim")

option (CPPCHECK_OFF "Disable cppcheck for the entire build" OFF)

#

function (oranges_enable_cppcheck target)

    if (NOT CPPCHECK_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable cppcheck, because cppcheck cannot be found. Set the CPPCHECK_PROGRAM variable to its location."
            )
        return ()
    endif ()

    if (CPPCHECK_OFF)
        message (VERBOSE
                 "${CMAKE_CURRENT_FUNCTION} - not enabling cppcheck, because CPPCHECK_OFF is ON.")
        return ()
    endif ()

    set (multiVal ENABLE DISABLE LANGS EXTRA_ARGS)

    cmake_parse_arguments (ORANGES_ARG "" "" "${multiVal}" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${target}' does not exist!")
    endif ()

    set (cppcheck_cmd "${CPPCHECK_PROGRAM}")

    #

    if (NOT ORANGES_ARG_EXTRA_ARGS)
        separate_arguments (ORANGES_ARG_EXTRA_ARGS UNIX_COMMAND "${CPPCHECK_EXTRA_ARGS}")
    endif ()

    if (ORANGES_ARG_EXTRA_ARGS)
        list (REMOVE_DUPLICATES ORANGES_ARG_EXTRA_ARGS)
        list (APPEND cppcheck_cmd ${ORANGES_ARG_EXTRA_ARGS})
    endif ()

    #

    if (NOT ORANGES_ARG_ENABLE)
        separate_arguments (ORANGES_ARG_ENABLE UNIX_COMMAND "${CPPCHECK_ENABLE}")
    endif ()

    list (REMOVE_DUPLICATES ORANGES_ARG_ENABLE)

    foreach (enable_check IN LISTS ORANGES_ARG_ENABLE)
        list (APPEND cppcheck_cmd "--enable=${enable_check}")
    endforeach ()

    #

    if (NOT ORANGES_ARG_DISABLE)
        separate_arguments (ORANGES_ARG_DISABLE UNIX_COMMAND "${CPPCHECK_DISABLE}")
    endif ()

    list (REMOVE_DUPLICATES ORANGES_ARG_DISABLE)

    foreach (disable_check IN LISTS ORANGES_ARG_DISABLE)
        list (APPEND cppcheck_cmd "--suppress=${disable_check}")
    endforeach ()

    #

    list (REMOVE_DUPLICATES cppcheck_cmd)

    message (DEBUG "cppcheck command for target ${target}: ${cppcheck_cmd}")

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

        set_target_properties ("${target}" PROPERTIES "${lang}_CPPCHECK" "${cppcheck_cmd}")

    endforeach ()

    set_target_properties ("${target}" PROPERTIES EXPORT_COMPILE_COMMANDS ON)

    message (VERBOSE "Enabled cppcheck for target ${target}")

endfunction ()
