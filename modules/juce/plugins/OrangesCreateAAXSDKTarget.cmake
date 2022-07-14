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

OrangesCreateAAXSDKTarget
-------------------------

This module creates a target to build the AAX SDK.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- AAXSDK

Input variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- LEMONS_AAX_SDK_PATH

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

lemons_warn_if_not_processing_project ()

oranges_file_scoped_message_context ("LemonsCreateAAXSDKTarget")

# currently broken on windows...
if (WIN32)
    return ()
endif ()

if (NOT (APPLE OR WIN32))
    return ()
endif ()

if (IOS OR ANDROID)
    return ()
endif ()

if (NOT LEMONS_AAX_SDK_PATH)
    return ()
endif ()

if (NOT IS_DIRECTORY "${LEMONS_AAX_SDK_PATH}")
    message (WARNING "LEMONS_AAX_SDK_PATH has been specified, but the directory does not exist!")
    return ()
endif ()

# Mac (xcodebuild)
if (APPLE)

    if (NOT "x86_64" IN_LIST CMAKE_OSX_ARCHITECTURES)
        message (
            WARNING
                "You're not building for x86_64, which will cause linker errors with AAX targets! Enable universal binaries to build for AAX."
            )
    endif ()

    find_package (xcodebuild REQUIRED QUIET)

    include_external_xcode_project (
        TARGET AAXSDK
        DIRECTORY "${LEMONS_AAX_SDK_PATH}/Libs/AAXLibrary/MacBuild"
        SCHEME AAXLibrary_libcpp
        EXTRA_ARGS "-arch x86_64 ONLY_ACTIVE_ARCH=NO"
        COMMENT "Building AAX SDK...")

    set_target_properties (AAXSDK PROPERTIES OSX_ARCHITECTURES x86_64)

elseif (WIN32)

    set (aax_msvc_proj_file "${LEMONS_AAX_SDK_PATH}/msvc/AAX_SDK.sln")

    if (NOT EXISTS "${aax_msvc_proj_file}")
        message (
            AUTHOR_WARNING "${aax_msvc_proj_file} could not be found, AAX SDK cannot be built!")
        return ()
    endif ()

    include_external_msproject (AAXSDK "${aax_msvc_proj_file}")

    unset (aax_msvc_proj_file)

endif ()

if (TARGET AAXSDK)
    message (VERBOSE "Configured AAXSDK target!")

    oranges_export_alias_target (AAXSDK Lemons)
else ()
    message (WARNING "Error configuring the AAXSDK target!")
endif ()