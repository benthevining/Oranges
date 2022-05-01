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

OrangesAssetsHelpers
-------------------------

This module provides the function :command:`lemons_add_resources_folder()`.


.. command:: lemons_add_resources_folder

  ::

    lemons_add_resources_folder (TARGET <target> ASSET_FOLDER <folder>
                                [OUTPUT_TARGET <targetName>])

Adds a JUCE binary data folder for the specified ``<target>``, and populates it with all the files found in ``<folder>``.
if ``<folder>`` is a relative path, it will be evaluated relative to your project's root directory (ie, the value of ``${PROJECT_SOURCE_DIR}`` when this function is called). You may also pass an absolute path.

If ``OUTPUT_TARGET`` is present, ``<targetName>`` will be the name of the generated resources target; otherwise, it will default to ``${PROJECT_NAME}-Assets``.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesJuceUtilities)
include (OrangesFileUtils)
include (OrangesCmakeDevTools)

lemons_warn_if_not_processing_project ()

function (lemons_add_resources_folder)

    oranges_add_function_message_context ()

    set (oneValueArgs TARGET ASSET_FOLDER OUTPUT_TARGET)

    cmake_parse_arguments (LEMONS_RSRC_FLDR "SHIM" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (LEMONS_RSRC_FLDR TARGET ASSET_FOLDER)
    lemons_check_for_unparsed_args (LEMONS_RSRC_FLDR)
    oranges_assert_target_argument_is_target (LEMONS_RSRC_FLDR)

    lemons_make_path_absolute (VAR LEMONS_RSRC_FLDR_ASSET_FOLDER
                               BASE_DIR "${PROJECT_SOURCE_DIR}")

    if (LEMONS_RSRC_FLDR_OUTPUT_TARGET)
        set (resourcesTarget "${LEMONS_RSRC_FLDR_OUTPUT_TARGET}")
    else ()
        set (resourcesTarget "${PROJECT_NAME}-Assets")
    endif ()

    lemons_make_variable_const (resourcesTarget)

    message (DEBUG "Assets target name: ${resourcesTarget}")
    message (DEBUG
             "Assets target source folder: ${LEMONS_RSRC_FLDR_ASSET_FOLDER}")

    if (NOT TARGET ${resourcesTarget})
        if (TARGET ${LEMONS_RSRC_FLDR_TARGET}::${resourcesTarget})
            message (
                AUTHOR_WARNING
                    "Target ${LEMONS_RSRC_FLDR_TARGET}::${resourcesTarget} exists, but target ${resourcesTarget} not found!"
                )
        endif ()

        lemons_subdir_list (DIR "${LEMONS_RSRC_FLDR_ASSET_FOLDER}"
                            FILES FULL_PATHS RECURSE RESULT files)

        if (NOT files)
            message (
                AUTHOR_WARNING
                    "No files found for inclusion in resources target!")
            return ()
        endif ()

        juce_add_binary_data (${resourcesTarget} SOURCES ${files})

        if (NOT TARGET ${resourcesTarget})
            message (WARNING "Error creating resources target.")
            return ()
        endif ()

        set_target_properties (${resourcesTarget}
                               PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
        target_compile_definitions (${resourcesTarget}
                                    INTERFACE LEMONS_HAS_BINARY_DATA=1)

        if (LEMONS_RSRC_FLDR_SHIM OR "$ENV{LEMONS_FORCE_BINARY_SHIM}")
            # cmake-lint: disable=E1126
            file (REAL_PATH "${LEMONS_RSRC_FLDR_ASSET_FOLDER}" abs_path)
            target_compile_definitions (
                ${resourcesTarget}
                INTERFACE LEMONS_BINARY_SHIM_ROOT=${abs_path})
            message (
                STATUS
                    "Enabling filesystem shim for binary data target: ${resourcesTarget}. Root dir: ${abs_path}"
                )
        endif ()

        oranges_export_alias_target ("${resourcesTarget}"
                                     "${LEMONS_RSRC_FLDR_TARGET}")
    endif ()

    if (NOT TARGET ${LEMONS_RSRC_FLDR_TARGET}::${resourcesTarget})
        message (
            AUTHOR_WARNING
                "Error creating resources target - target ${LEMONS_RSRC_FLDR_TARGET}::${resourcesTarget} not found."
            )
        return ()
    endif ()

    juce_add_bundle_resources_directory (${LEMONS_RSRC_FLDR_TARGET}
                                         ${LEMONS_RSRC_FLDR_ASSET_FOLDER})

    target_link_libraries (
        ${LEMONS_RSRC_FLDR_TARGET}
        PRIVATE ${LEMONS_RSRC_FLDR_TARGET}::${resourcesTarget})

endfunction ()
