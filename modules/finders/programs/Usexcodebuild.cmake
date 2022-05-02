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

Usexcodebuild
-------------------------

Include external Xcode projects in your build.
If xcodebuild hasn't already been found, including this module will call ``find_package(xcodebuild)``.


Include an external XCode project
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: include_external_xcode_project

  ::

    include_external_xcode_project (TARGET <targetName>
                                    DIRECTORY <dirOfXcodeProject>
                                    SCHEME <nameOfScheme>
                                   [EXTRA_ARGS <extraXcodebuildArgs>]
                                   [COMMENT <buildComment>])

Adds an external Xcode project to the build, similar to the CMake-native include_external_msproject command.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

if (NOT TARGET Apple::xcodebuild)
    find_package (xcodebuild REQUIRED)
endif ()

#

function (include_external_xcode_project)

    oranges_add_function_message_context ()

    set (oneValueArgs TARGET DIRECTORY SCHEME EXTRA_ARGS COMMENT)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG TARGET DIRECTORY SCHEME)
    lemons_check_for_unparsed_args (ORANGES_ARG)

    if (NOT TARGET Apple::xcodebuild)
        message (FATAL_ERROR "xcodebuild cannot be found, xcode project target cannot be created!")
        return ()
    endif ()

    if (NOT ORANGES_ARG_COMMENT)
        set (ORANGES_ARG_COMMENT "Building ${ORANGES_ARG_TARGET}...")
    endif ()

    add_custom_target (
        "${ORANGES_ARG_TARGET}"
        COMMAND Apple::xcodebuild -scheme "${ORANGES_ARG_SCHEME}" -configuration
                $<COMMAND_CONFIG:$<CONFIG>> ${ORANGES_ARG_EXTRA_ARGS} build
        COMMAND_EXPAND_LISTS VERBATIM USES_TERMINAL
        WORKING_DIRECTORY "${ORANGES_ARG_DIRECTORY}"
        COMMENT "${ORANGES_ARG_COMMENT}"
        COMMAND_ECHO STDOUT)

endfunction ()
