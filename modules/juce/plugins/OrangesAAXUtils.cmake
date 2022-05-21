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

OrangesAAXUtils
-------------------------

This module provides the function :command:`lemons_configure_aax_plugin()`.

.. command:: lemons_configure_aax_plugin

  ::

    lemons_configure_aax_plugin (TARGET <target>
                                [PAGETABLE_FILE <file>]
                                [GUID <guid>])

Configures default settings for the specified AAX plugin target. Note that ``<target>`` is the *literal* name of this plugin target, not the shared plugin target name!

``PAGETABLE_FILE`` is optional and specifies the name of an AAX pagetable file within your resources target to use.

If ``GUID`` is present, ``${ARGN}`` will be forwarded to :command:`lemons_configure_aax_plugin_signing`.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCreateAAXSDKTarget)
include (OrangesFileUtils)
include (OrangesJuceUtilities)
include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("LemonsAAXUtils")

if (TARGET Lemons::AAXSDK)
    juce_set_aax_sdk_path ("${LEMONS_AAX_SDK_PATH}")
    message (DEBUG "AAXSDK target created successfully!")
else ()
    message (DEBUG "AAXSDK target not created, see log for errors...")
endif ()

#

function (lemons_configure_aax_plugin)

    oranges_add_function_message_context ()

    set (oneValueArgs TARGET PAGETABLE_FILE)

    cmake_parse_arguments (LEMONS_AAX "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (LEMONS_AAX TARGET)
    lemons_check_for_unparsed_args (LEMONS_AAX)

    if (NOT TARGET ${LEMONS_AAX_TARGET})
        message (WARNING "AAX target does not exist!")
        return ()
    endif ()

    if (NOT TARGET Lemons::AAXSDK)
        message (FATAL_ERROR "AAX plugin target created, but AAXSDK target doesn't exist!")
    endif ()

    set_target_properties (${LEMONS_AAX_TARGET} PROPERTIES OSX_ARCHITECTURES x86_64)

    add_dependencies (${LEMONS_AAX_TARGET} Lemons::AAXSDK)

    if (LEMONS_AAX_PAGETABLE_FILE)

        message (DEBUG "Configuring AAX pagetable file...")

        lemons_make_path_absolute (VAR LEMONS_AAX_PAGETABLE_FILE BASE_DIR ${PROJECT_SOURCE_DIR})

        cmake_path (IS_ABSOLUTE LEMONS_AAX_PAGETABLE_FILE pagetable_path_is_absolute)

        target_compile_definitions (
            ${LEMONS_AAX_TARGET}
            PRIVATE "JucePlugin_AAXPageTableFile=\"${LEMONS_AAX_PAGETABLE_FILE}\"")

        if (WIN32)
            # On Windows, pagetable files need a special post-build copy step to be included in the
            # binary correctly
            add_custom_command (
                TARGET ${LEMONS_AAX_TARGET}
                POST_BUILD VERBATIM
                COMMAND
                    "${CMAKE_COMMAND}" ARGS -E copy "${LEMONS_AAX_PAGETABLE_FILE}"
                    "$<TARGET_PROPERTY:${LEMONS_AAX_TARGET},JUCE_PLUGIN_ARTEFACT_FILE>/Contents/Resources"
                COMMENT "Copying AAX pagetable into AAX binary...")
        endif ()
    endif ()
endfunction ()
