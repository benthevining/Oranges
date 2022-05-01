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

OrangesDefaultTarget
-------------------------

Provides a helper "default target" with some sensible defaults configured.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesDefaultTarget

Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ORANGES_MAC_UNIVERSAL_BINARY (macOS only)

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- APPLE_DEV_ID

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesDefaultTarget)
    return ()
endif ()

include (OrangesCmakeDevTools)
include (OrangesConfigurationPostfixes)

#

if (APPLE)
    if (NOT IOS)
        option (ORANGES_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)
        mark_as_advanced (FORCE ORANGES_MAC_UNIVERSAL_BINARY)
    endif ()
else ()
    if (UNIX AND NOT WIN32)
        set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
        set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")

        include (LinuxLSBInfo)
    endif ()
endif ()

#

define_property (
    TARGET INHERITED
    PROPERTY ORANGES_USING_INSTALLED_PACKAGE
    BRIEF_DOCS
        "TRUE if this target has been linked to from outside the original build tree; otherwise FALSE"
    FULL_DOCS
        "Boolean indicator of whether this target is being consumed downstream as an installed version"
    )

define_property (
    TARGET INHERITED
    PROPERTY ORANGES_MAC_UNIVERSAL_BINARY
    BRIEF_DOCS "TRUE if building a universal binary; otherwise FALSE"
    FULL_DOCS
        "When TRUE, the OSX architectures have been set to x86_64 and arm64; when false, it has been set to only this Mac's native architecture. FALSE on non-MacOSX platforms."
    )

define_property (
    GLOBAL
    PROPERTY ORANGES_MAC_NATIVE_ARCH
    BRIEF_DOCS
        "String describing this Mac's native processor architecture; either x86_64 (Intel) or arm64 (M1)"
    FULL_DOCS
        "String describing this Mac's native processor architecture; either x86_64 (Intel) or arm64 (M1). Undefined on non-MacOSX platforms."
    )

if (ORANGES_PROPERTIES_LIST_FILE)
    file (
        APPEND "${ORANGES_PROPERTIES_LIST_FILE}"
        "ORANGES_USING_INSTALLED_PACKAGE TARGET\nORANGES_MAC_UNIVERSAL_BINARY TARGET\nORANGES_MAC_NATIVE_ARCH GLOBAL\n"
        )
endif ()

#

add_library (OrangesDefaultTarget INTERFACE)

set_target_properties (
    OrangesDefaultTarget
    PROPERTIES C_EXTENSIONS OFF
               CXX_EXTENSIONS OFF
               EXPORT_COMPILE_COMMANDS ON
               OPTIMIZE_DEPENDENCIES ON
               PCH_WARN_INVALID ON
               PCH_INSTANTIATE_TEMPLATES ON
               VISIBILITY_INLINES_HIDDEN ON
               DEBUG_POSTFIX "${ORANGES_DEBUG_POSTFIX}"
               MINSIZEREL_POSTFIX "${ORANGES_MINSIZEREL_POSTFIX}"
               RELEASE_POSTFIX "${ORANGES_RELEASE_POSTFIX}"
               RELWITHDEBINFO_POSTFIX "${ORANGES_RELWITHDEBINFO_POSTFIX}"
               $<BUILD_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE FALSE>
               $<INSTALL_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE TRUE>)

set_property (
    TARGET OrangesDefaultTarget APPEND
    PROPERTY EXPORT_PROPERTIES ORANGES_MAC_UNIVERSAL_BINARY
             ORANGES_USING_INSTALLED_PACKAGE)

target_compile_definitions (
    OrangesDefaultTarget
    INTERFACE "$<$<PLATFORM_ID:Windows>:NOMINMAX;UNICODE;STRICT>")

set (compiler_gcclike "$<CXX_COMPILER_ID:Clang,AppleClang,GNU>")

target_compile_options (
    OrangesDefaultTarget
    INTERFACE
        "$<$<CXX_COMPILER_ID:MSVC>:/wd4068;/MP>"
        "$<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<CXX_COMPILER_ID:Clang>>>:/EHsc>"
        "$<${compiler_gcclike}:-g>")

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

unset (debug_configs)

set (config_is_release "$<NOT:${config_is_debug}>")

set_target_properties (
    OrangesDefaultTarget PROPERTIES MSVC_RUNTIME_LIBRARY
                                    "MultiThreaded$<${config_is_debug}:Debug>")

target_compile_options (
    OrangesDefaultTarget
    INTERFACE
        "$<$<AND:${compiler_gcclike},${config_is_debug}>:-O0>"
        "$<$<AND:${compiler_gcclike},${config_is_release}>:-O3>"
        "$<$<AND:${compiler_gcclike},${config_is_release},$<NOT:$<PLATFORM_ID:MINGW>>>:-flto>"
        "$<$<AND:$<CXX_COMPILER_ID:MSVC>,${config_is_debug}>:/Od;/Zi>"
        "$<$<AND:$<CXX_COMPILER_ID:MSVC>,${config_is_release}>:/Ox;-GL>")

target_link_libraries (
    OrangesDefaultTarget
    INTERFACE "$<$<AND:$<CXX_COMPILER_ID:MSVC>,${config_is_release}>:-LTCG>")

unset (compiler_gcclike)
unset (config_is_debug)
unset (config_is_release)

#

# cmake-lint: disable=W0106
if (DEFINED ENV{APPLE_DEV_ID})
    set (ORANGES_IOS_DEV_TEAM_ID "$ENV{APPLE_DEV_ID}"
         CACHE STRING "10-character Apple Developer ID")
endif ()

set (ios_like_systems iOS tvOS watchOS)

set (ios_like "$<IN_LIST:$<PLATFORM_ID>,${ios_like_systems}>")

unset (ios_like_systems)

set (any_apple_system "$<OR:$<PLATFORM_ID:Darwin>,${ios_like}>")

# cmake-format: off
set_target_properties (
	OrangesDefaultTarget
	PROPERTIES $<$<NOT:${any_apple_system}>:INSTALL_RPATH $ORIGIN>
			   $<${any_apple_system}:XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES>
			   $<${any_apple_system}:XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET ${CMAKE_OSX_DEPLOYMENT_TARGET}>
			   $<${ios_like}:ARCHIVE_OUTPUT_DIRECTORY ./>
			   $<${ios_like}:XCODE_ATTRIBUTE_INSTALL_PATH $(LOCAL_APPS_DIR)>
			   $<${ios_like}:XCODE_ATTRIBUTE_SKIP_INSTALL NO>
			   $<${ios_like}:XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO>
			   $<${ios_like}:IOS_INSTALL_COMBINED ON>)

if (ORANGES_IOS_DEV_TEAM_ID)
	set_target_properties (
		OrangesDefaultTarget
		PROPERTIES $<${ios_like}:XCODE_ATTRIBUTE_DEVELOPMENT_TEAM \"${ORANGES_IOS_DEV_TEAM_ID}\">
				   $<${ios_like}:XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY \"iPhone Developer\">)
endif ()
# cmake-format: on

unset (any_apple_system)
unset (ios_like)

if (APPLE)
    execute_process (COMMAND uname -m OUTPUT_VARIABLE osx_native_arch
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

    message (DEBUG "Mac native arch: ${osx_native_arch}")

    set_property (GLOBAL PROPERTY ORANGES_MAC_NATIVE_ARCH "${osx_native_arch}")

    # cmake-format: off
	if (("${osx_native_arch}" STREQUAL "arm64") AND ORANGES_MAC_UNIVERSAL_BINARY AND XCODE)

		set_target_properties (
			OrangesDefaultTarget
			PROPERTIES $<$<PLATFORM_ID:Darwin>:OSX_ARCHITECTURES x86_64$<SEMICOLON>arm64>
					   $<$<PLATFORM_ID:Darwin>:ORANGES_MAC_UNIVERSAL_BINARY TRUE>)

		message (VERBOSE "  -- Enabling universal binary")
	else ()
		set_target_properties (
			OrangesDefaultTarget
			PROPERTIES $<$<PLATFORM_ID:Darwin>:OSX_ARCHITECTURES ${osx_native_arch}>
					   $<$<PLATFORM_ID:Darwin>:ORANGES_MAC_UNIVERSAL_BINARY FALSE>)
		# cmake-format: on

        message (VERBOSE "  -- DISABLING universal binary")
    endif ()

    unset (osx_native_arch)
endif ()

if (NOT DEFINED CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    include (CheckIPOSupported)

    check_ipo_supported (RESULT CMAKE_INTERPROCEDURAL_OPTIMIZATION)
endif ()

if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    set_target_properties (OrangesDefaultTarget
                           PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
else ()
    set_target_properties (OrangesDefaultTarget
                           PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)
endif ()

set_target_properties (OrangesDefaultTarget
                       PROPERTIES INTERPROCEDURAL_OPTIMIZATION_DEBUG OFF)

#

install (TARGETS OrangesDefaultTarget EXPORT OrangesTargets)

add_library (Oranges::OrangesDefaultTarget ALIAS OrangesDefaultTarget)
