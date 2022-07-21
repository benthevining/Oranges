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

Usewraptool
-------------------------

Configure AAX plugin signing using PACE's wraptool program.

Configure AAX signing with wraptool
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: wraptool_configure_aax_plugin_signing

  ::

    wraptool_configure_aax_plugin_signing (<targetName>
                                           GUID <guid>
                                          [ACCOUNT <accountID>]
                                          [SIGNID <signID>]
                                          [KEYFILE <keyfilePath>]
                                          [KEYPASSWORD <password>])

Configures signing of an AAX plugin target. Does nothing on Linux.

The ``ACCOUNT``, ``SIGNID``, ``KEYFILE``, and ``KEYPASSWORD`` options set the cache variables ``WRAPTOOL_ACCOUNT``, ``WRAPTOOL_SIGNID``, ``WRAPTOOL_KEYFILE``, and ``WRAPTOOL_KEYPASSWORD``, respectively.
When this module is included, each of these cache variables is also initialized with the value of the corresponding environment variable with the same name, if it is defined.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PROGRAM_WRAPTOOL

Path to the wraptool executable


.. cmake:variable:: WRAPTOOL_ACCOUNT


.. cmake:variable:: WRAPTOOL_SIGNID


.. cmake:variable:: WRAPTOOL_KEYFILE


.. cmake:variable:: WRAPTOOL_KEYPASSWORD


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

#

find_program (WRAPTOOL_PROGRAM wraptool PATHS ENV WRAPTOOL_PROGRAM DOC "PACE wraptool program")

set (WRAPTOOL_ACCOUNT "" CACHE STRING "Default wraptool account ID")

set (WRAPTOOL_SIGNID "" CACHE STRING "Default wraptool sign ID")

set (WRAPTOOL_KEYFILE "" CACHE FILEPATH "Default wraptool keyfile path")

set (WRAPTOOL_KEYPASSWORD "" CACHE STRING "Default wraptool key password")

mark_as_advanced (WRAPTOOL_PROGRAM WRAPTOOL_ACCOUNT WRAPTOOL_SIGNID WRAPTOOL_KEYFILE
                  WRAPTOOL_KEYPASSWORD)

#

function (wraptool_configure_aax_plugin_signing target)

    if (NOT WRAPTOOL_PROGRAM)
        message (
            WARNING
                "wraptool not found, codesigning cannot be configured. Set WRAPTOOL_PROGRAM to its location."
            )
        return ()
    endif ()

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${target}!")
    endif ()

    set (oneValueArgs GUID ACCOUNT SIGNID KEYFILE KEYPASSWORD)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    oranges_require_function_arguments (ORANGES_ARG GUID)
    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_ACCOUNT)
        set (ORANGES_ARG_ACCOUNT "${WRAPTOOL_ACCOUNT}")
    endif ()

    if (NOT ORANGES_ARG_SIGNID)
        set (ORANGES_ARG_SIGNID "${WRAPTOOL_SIGNID}")
    endif ()

    if (NOT ORANGES_ARG_KEYFILE)
        set (ORANGES_ARG_KEYFILE "${WRAPTOOL_KEYFILE}")
    endif ()

    if (NOT ORANGES_ARG_KEYPASSWORD)
        set (ORANGES_ARG_KEYPASSWORD "${WRAPTOOL_KEYPASSWORD}")
    endif ()

    set (dest "$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>")

    # cmake-format: off
    if (APPLE)

        add_custom_command (
            TARGET "${target}"
            POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
            COMMAND
                "${WRAPTOOL_PROGRAM}"
                ARGS sign --verbose --dsig1-compat off
                    --account "${ORANGES_ARG_ACCOUNT}"
                    --wcguid "${ORANGES_ARG_GUID}"
                    --signid "${ORANGES_ARG_SIGNID}"
                    --in "${dest}"
                    --out "${dest}"
            COMMENT "Signing ${target}...")

    elseif (WIN32)

        add_custom_command (
            TARGET "${target}"
            POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
            COMMAND
                "${WRAPTOOL_PROGRAM}"
                ARGS sign --verbose --dsig1-compat off
                    --account "${ORANGES_ARG_ACCOUNT}"
                    --keyfile "${ORANGES_ARG_KEYFILE}"
                    --keypassword "${ORANGES_ARG_KEYPASSWORD}"
                    --wcguid "${ORANGES_ARG_GUID}"
                    --in "${dest}"
                    --out "${dest}"
            COMMENT "Signing ${target}...")
    endif ()
    # cmake-format: on

endfunction ()
