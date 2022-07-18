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

        oranges_enable_clang_tidy (<target>
                                  [CONFIG_FILE <file>]
                                  [EXTRA_ARGS <args...>]
                                  [LANGS <C|CXX|OBJC|OBJCXX>...])

Configures clang-tidy for the given ``<target>`` by manipulating the target's ``<LANG>_CLANG_TIDY`` properties.

If the :variable:`CLANGTIDY_OFF` variable is set to ``ON``, this function does nothing.

Options:

``CONFIG_FILE``
 May be specified to provide a custom ``.clang-tidy`` file to be used for running clang-tidy on this target.
 If a relative path is given, it will be evaluated relative to the value of ``CMAKE_CURRENT_LIST_DIR`` when this function
 is called. If this argument is not specified, the value of the :variable:`CLANGTIDY_CONFIG_FILE` variable will be used.
 Providing this argument is equivalent to passing ``EXTRA_ARGS --config-file=<file>``.

``EXTRA_ARGS``
 Extra arguments that will be passed verbatim to the clang-tidy executable. If not specified, the value of the
 :variable:`CLANGTIDY_EXTRA_ARGS` variable will be used.

``LANGS``
 Languages for which to enable clang-tidy. Valid values are ``C``, ``CXX``, ``OBJC``, or ``OBJCXX``.
 If no languages are specified, this function will configure clang-tidy for all four valid languages.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CLANGTIDY_PROGRAM

Path to the clang-tidy executable, used by :command:`oranges_enable_clang_tidy`.
An environment variable with this name may also be set.


.. cmake:variable:: CLANGTIDY_CONFIG_FILE

This variable may be set to a ``.clang-tidy`` file that will be used for all calls to :command:`oranges_enable_clang_tidy`
that do not explicitly provide their own config file. The environment variable with this name, if set, will initialize
this cache variable.


.. cmake:variable:: CLANGTIDY_EXTRA_ARGS

This variable may be set to a list of space-separated arguments that will be passed to clang-tidy verbatim for the
:command:`oranges_enable_clang_tidy` command. The environment variable with this name, if set, will initialize
this cache variable.


.. cmake:variable:: CLANGTIDY_OFF

When this variable is set to ``ON``, calls to :command:`oranges_enable_clang_tidy` do nothing. If an environment variable
with this name is set, it will initialize this cache variable's value; otherwise, this variable will default to ``OFF``.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CLANGTIDY_PROGRAM

Initializes the value of the :variable:`CLANGTIDY_PROGRAM` variable.


.. cmake:envvar:: CLANGTIDY_CONFIG_FILE

Initializes the :variable:`CLANGTIDY_CONFIG_FILE` variable.


.. cmake:envvar:: CLANGTIDY_EXTRA_ARGS

Initializes the :variable:`CLANGTIDY_EXTRA_ARGS` variable.


.. cmake:envvar:: CLANGTIDY_OFF

Initializes the :variable:`CLANGTIDY_OFF` variable.


.. seealso ::

    Module :module:`OrangesCppcheck`
        Module for cppcheck

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

find_program (CLANGTIDY_PROGRAM clang-tidy PATHS ENV CLANGTIDY_PROGRAM
              DOC "Path to the clang-tidy executable")

set (CLANGTIDY_CONFIG_FILE "$ENV{CLANGTIDY_CONFIG_FILE}"
     CACHE FILEPATH "Default .clang-tidy file to be used")

set (CLANGTIDY_EXTRA_ARGS "$ENV{CLANGTIDY_EXTRA_ARGS}"
     CACHE STRING "Space-separated extra arguments to be passed to clang-tidy verbatim")

if (DEFINED ENV{CLANGTIDY_OFF})
    set (ct_off_init "$ENV{CLANGTIDY_OFF}")
else ()
    set (ct_off_init OFF)
endif ()

option (CLANGTIDY_OFF "Disable clang-tidy for the entire build" "${ct_off_init}")

unset (ct_off_init)

#

function (oranges_enable_clang_tidy target)

    if (NOT CLANGTIDY_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable clang-tidy, because clang-tidy cannot be found. Set the CLANGTIDY_PROGRAM variable to its location."
            )
        return ()
    endif ()

    if (CLANGTIDY_OFF)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - not enabling clang-tidy, because CLANGTIDY_OFF is ON.")
        return ()
    endif ()

    set (oneVal CONFIG_FILE)
    set (multiVal LANGS EXTRA_ARGS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "${multiVal}" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${target}' does not exist!")
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
        list (REMOVE_DUPLICATES ORANGES_ARG_EXTRA_ARGS)
        list (APPEND clangtidy_cmd ${ORANGES_ARG_EXTRA_ARGS})
    endif ()

    #

    list (REMOVE_DUPLICATES clangtidy_cmd)

    message (DEBUG "clang-tidy command for target ${target}: ${clangtidy_cmd}")

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

        set_target_properties ("${target}" PROPERTIES "${lang}_CLANG_TIDY" "${clangtidy_cmd}")

    endforeach ()

    set_target_properties ("${target}" PROPERTIES EXPORT_COMPILE_COMMANDS ON)

    message (VERBOSE "Enabled clang-tidy for target ${target}")

endfunction ()
