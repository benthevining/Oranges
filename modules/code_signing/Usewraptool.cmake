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

    wraptool_configure_aax_plugin_signing (TARGET <targetName>
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

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: WRAPTOOL_ACCOUNT

Initializes the :variable:`WRAPTOOL_ACCOUNT` variable when this module is included.

.. cmake:envvar:: WRAPTOOL_SIGNID

Initializes the :variable:`WRAPTOOL_SIGNID` variable when this module is included.

.. cmake:envvar:: WRAPTOOL_KEYFILE

Initializes the :variable:`WRAPTOOL_KEYFILE` variable when this module is included.

.. cmake:envvar:: WRAPTOOL_KEYPASSWORD

Initializes the :variable:`WRAPTOOL_KEYPASSWORD` variable when this module is included.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

#

find_program (PROGRAM_WRAPTOOL wraptool DOC "PACE wraptool program")

mark_as_advanced (FORCE PROGRAM_WRAPTOOL)

#

if (DEFINED ENV{WRAPTOOL_ACCOUNT})
    set (WRAPTOOL_ACCOUNT "$ENV{WRAPTOOL_ACCOUNT}" CACHE STRING "wraptool account ID")
endif ()

if (DEFINED ENV{WRAPTOOL_SIGNID})
    set (WRAPTOOL_SIGNID "$ENV{WRAPTOOL_SIGNID}" CACHE STRING "wraptool sign ID")
endif ()

if (DEFINED ENV{WRAPTOOL_KEYFILE})
    set (WRAPTOOL_KEYFILE "$ENV{WRAPTOOL_SIGNID}" CACHE FILEPATH "wraptool keyfile path")
endif ()

if (DEFINED ENV{WRAPTOOL_KEYPASSWORD})
    set (WRAPTOOL_KEYPASSWORD "$ENV{WRAPTOOL_KEYPASSWORD}" CACHE STRING "wraptool key password")
endif ()

#

function (wraptool_configure_aax_plugin_signing)

    if (NOT PROGRAM_WRAPTOOL)
        message (
            WARNING
                "wraptool not found, codesigning cannot be configured. Set PROGRAM_WRAPTOOL to its location."
            )
        return ()
    endif ()

    oranges_add_function_message_context ()

    set (oneValueArgs TARGET GUID ACCOUNT SIGNID KEYFILE KEYPASSWORD)

    cmake_parse_arguments (LEMONS_AAX "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (LEMONS_AAX TARGET GUID)
    lemons_check_for_unparsed_args (LEMONS_AAX)

    if (NOT TARGET PACE::wraptool)
        message (FATAL_ERROR "wraptool program not found, AAX signing cannot be configured!")
        return ()
    endif ()

    if (NOT TARGET "${LEMONS_AAX_TARGET}")
        message (
            FATAL_ERROR
                "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${LEMONS_AAX_TARGET}!")
    endif ()

    set (WRAPTOOL_ACCOUNT "${LEMONS_AAX_ACCOUNT}" CACHE STRING "wraptool account ID")
    set (WRAPTOOL_SIGNID "${LEMONS_AAX_SIGNID}" CACHE STRING "wraptool sign ID")
    set (WRAPTOOL_KEYFILE "${LEMONS_AAX_KEYFILE}" CACHE FILEPATH "wraptool keyfile path")
    set (WRAPTOOL_KEYPASSWORD "${LEMONS_AAX_KEYPASSWORD}" CACHE STRING "wraptool key password")

    if (APPLE)
        add_custom_command (
            TARGET "${LEMONS_AAX_TARGET}"
            POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
            COMMAND
                "${PROGRAM_WRAPTOOL}" ARGS sign --verbose --dsig1-compat off --account
                "${WRAPTOOL_ACCOUNT}" --wcguid "${LEMONS_AAX_GUID}" --signid "${WRAPTOOL_SIGNID}"
                --in "$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>" --out
                "$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>"
            COMMENT "Signing ${LEMONS_AAX_TARGET}...")

    elseif (WIN32)
        add_custom_command (
            TARGET "${LEMONS_AAX_TARGET}"
            POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
            COMMAND
                "${PROGRAM_WRAPTOOL}" ARGS sign --verbose --dsig1-compat off --account
                "${WRAPTOOL_ACCOUNT}" --keyfile "${WRAPTOOL_KEYFILE}" --keypassword
                "${WRAPTOOL_KEYPASSWORD}" --wcguid "${LEMONS_AAX_GUID}" --in
                "$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>" --out
                "$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>"
            COMMENT "Signing ${LEMONS_AAX_TARGET}...")
    else ()
        return ()
    endif ()

    message (DEBUG "Configured AAX plugin signing!")

endfunction ()
