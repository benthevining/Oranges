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

OrangesClangFormat
--------------------

This module provides integration with the clang-format tool.

.. command:: oranges_enable_clangformat

    ::

        oranges_enable_clangformat (<target>
                                   [POST_BUILD] [TARGET_NAME <targetName>]
                                   [USE_FILE] | [STYLE <LLVM|Google|Chromium|Mozilla|WebKit>])

Adds rules to format ``<target>``'s sources using clang-format.

The target's sources are automatically detected using generator expressions.

Options:

``POST_BUILD``
 If this flag is present, a post-build command will be added to ``<target>`` to invoke clang-format.
 Note that this may be used in conjunction with the ``TARGET_NAME`` option.

``TARGET_NAME``
 If present, creates a custom target named ``<targetName>`` that executes clang-format to format
 ``<target>``'s sources. Note that this may be used in conjunction with the ``POST_BUILD`` flag.

``USE_FILE``
 If present, clang-format will search for a ``.clang-format`` file in the parent directories of each file
 being formatted. If this file cannot be found, formatting will be skipped. Usage of this flag is
 mutually exclusive with the ``STYLE`` option.

``STYLE``
 Specify a formatting style to use.

If neither ``USE_FILE`` or ``STYLE`` are given, the value of the :variable:`CLANGFORMAT_STYLE` variable
will be specified as the style for clang-format to use.


Cache variables
^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CLANGFORMAT_PROGRAM

Path to the clang-format executable. The environment variable with this name, if set, will initialize
this variable.


.. cmake:variable:: CLANGFORMAT_STYLE

Default style to use for calls to :command:`oranges_enable_clangformat` that do not explicitly override
this option. The environment variable with this name, if set, will initialize this variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

find_program (CLANGFORMAT_PROGRAM clang-format PATHS ENV CLANGFORMAT_PROGRAM
              DOC "Path to the clang-format executable")

if (DEFINED ENV{CLANGFORMAT_STYLE})
    set (cf_style_init "$ENV{CLANGFORMAT_STYLE}")
else ()
    set (cf_style_init LLVM)
endif ()

set (CLANGFORMAT_STYLE "${cf_style_init}" CACHE STRING "Default style to use for clang-format")

unset (cf_style_init)

set_property (CACHE CLANGFORMAT_STYLE PROPERTY STRINGS LLVM Google Chromium Mozilla WebKit)

mark_as_advanced (CLANGFORMAT_PROGRAM CLANGFORMAT_STYLE)

#

function (oranges_enable_clangformat target)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
    endif ()

    if (NOT CLANGFORMAT_PROGRAM)
        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - cannot enable clang-format, because clang-format was not found"
            )
        return ()
    endif ()

    set (options POST_BUILD USE_FILE)
    set (oneVal TARGET_NAME STYLE)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneVal}" "" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT (ORANGES_ARG_POST_BUILD OR ORANGES_ARG_TARGET_NAME))
        message (
            AUTHOR_WARNING
                "${CMAKE_CURRENT_FUNCTION} - this function does nothing if neither POST_BUILD or TARGET_NAME are specified!"
            )
    endif ()

    set (command "${CLANGFORMAT_PROGRAM}")

    if (ORANGES_ARG_USE_FILE)
        list (APPEND command "--style=file" "--fallback-style=none")
    elseif (ORANGES_ARG_STYLE)
        list (APPEND command "--style=${ORANGES_ARG_STYLE}")
    else ()
        list (APPEND command "--style=${CLANGFORMAT_STYLE}")
    endif ()

    list (APPEND command -i "$<TARGET_PROPERTY:SOURCES>")

    message (DEBUG "${CMAKE_CURRENT_FUNCTION} - clang-format command for ${target}: ${command}")

    if (ORANGES_ARG_POST_BUILD)
        add_custom_command (
            TARGET "${target}"
            POST_BUILD
            COMMAND ${command}
            COMMENT "Running clang-format on ${target}..."
            VERBATIM USES_TERMINAL COMMAND_EXPAND_LISTS)
    endif ()

    if (ORANGES_ARG_TARGET_NAME)
        add_custom_target (
            "${ORANGES_ARG_TARGET_NAME}" COMMAND ${command}
            COMMENT "Running clang-format on ${target}..." VERBATIM USES_TERMINAL
                                                           COMMAND_EXPAND_LISTS)
    endif ()

endfunction ()
