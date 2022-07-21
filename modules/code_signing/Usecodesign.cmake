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

Usecodesign
-------------------------

Configure code signing of targets using Apple's codesign tool.

.. command:: codesign_sign_target

  ::

    codesign_sign_target (<targetName>
                         [IDENTITY <id>])

Adds a post-build command to the specified target to run codesign on the target's bundle.

If ``IDENTITY`` is not provided, the value of the :variable:`CODESIGN_ID` variable will be used.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CODESIGN_PROGRAM

Path to the codesign executable.


.. cmake:variable:: CODESIGN_ID

Default sign identity used in calls to :command:`codesign_sign_target` that do not
explicitly override this option. An environment variable with this name, if set, initializes this
cache variable.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CODESIGN_ID

Initializes the :variable:`CODESIGN_ID` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

find_program (CODESIGN_PROGRAM codesign PATHS ENV CODESIGN_PROGRAM DOC "Apple's codesign program")

set (CODESIGN_ID "$ENV{CODESIGN_ID}" CACHE STRING "Default codesign identity")

mark_as_advanced (CODESIGN_PROGRAM CODESIGN_ID)

#

function (codesign_sign_target target)

    if (NOT CODESIGN_PROGRAM)
        message (
            WARNING
                "codesign not found, codesigning cannot be configured. Set CODESIGN_PROGRAM to its location."
            )
        return ()
    endif ()

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${target}!")
    endif ()

    cmake_parse_arguments (ORANGES_ARG "" "IDENTITY" "" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_IDENTITY)
        set (ORANGES_ARG_IDENTITY "${CODESIGN_ID}")
    endif ()

    if (NOT ORANGES_ARG_IDENTITY)
        message (
            WARNING
                "${CMAKE_CURRENT_FUNCTION} - IDENTITY was not provided, and CODESIGN_ID is not set. Cannot enable code signing!"
            )
        return ()
    endif ()

    set (dest "$<TARGET_BUNDLE_DIR:${target}>")

    add_custom_command (
        TARGET "${target}"
        POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
        COMMAND "${CODESIGN_PROGRAM}" -s "${ORANGES_ARG_IDENTITY}" "${dest}"
        COMMAND "${CODESIGN_PROGRAM}" -v "${dest}"
        COMMENT "Signing ${target}...")

endfunction ()
