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

The default target will have configuration postfixes and appropriate configuration-specific optimization flags configured.

The default target will have the following compiler definitions added:
- ORANGES_DEBUG : 1 if the configuration is a debug configuration, 0 otherwise
- ORANGES_RELEASE: 1 if the configuration is a release configuration, 0 otherwise
- ORANGES_BUILD_TYPE : A string literal with the exact name of the build configuration that was used.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesDefaultTarget
- Oranges::OrangesDefaultCXXTarget : links to OrangesDefaultTarget, but also has some default C++ compile features added. The C++ standard used by this target is C++20, and it has exceptions and RTTI enabled by default.

Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ORANGES_MAINTAINER_BUILD
- ORANGES_MAC_UNIVERSAL_BINARY

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
include (FeatureSummary)

#

option (ORANGES_MAINTAINER_BUILD "Enables integrations and warnings in OrangesDefaultTarget" OFF)

option (ORANGES_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)

if (UNIX AND NOT (WIN32 OR APPLE))
    set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
    set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")

    include (LinuxLSBInfo)
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
               DEBUG_POSTFIX -d
               MINSIZEREL_POSTFIX -rm
               RELEASE_POSTFIX -r
               RELWITHDEBINFO_POSTFIX -rd
               $<BUILD_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE FALSE>
               $<INSTALL_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE TRUE>)

set_property (
    TARGET OrangesDefaultTarget APPEND PROPERTY EXPORT_PROPERTIES ORANGES_MAC_UNIVERSAL_BINARY
                                                ORANGES_USING_INSTALLED_PACKAGE)

set (windowsDefs # cmake-format: sortable
                 _CRT_SECURE_NO_WARNINGS NOMINMAX STRICT UNICODE)

target_compile_definitions (OrangesDefaultTarget
                            INTERFACE "$<$<PLATFORM_ID:Windows>:${windowsDefs}>")

unset (windowsDefs)

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

if (WIN32)
    set (intel_opts /Gm)
else ()
    set (intel_opts -multiple-processes=4 -static-intel)
endif ()

target_compile_options (
    OrangesDefaultTarget
    INTERFACE "$<$<CXX_COMPILER_ID:MSVC>:/wd4068;/MP>"
              "$<$<AND:$<PLATFORM_ID:Windows>,$<CXX_COMPILER_ID:GNU>>:-municode;-mwin32>"
              "$<${compiler_intel}:${intel_opts}>")

unset (intel_opts)

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

unset (debug_configs)

set (config_is_release "$<NOT:${config_is_debug}>")

target_compile_definitions (
    OrangesDefaultTarget
    INTERFACE "$<${config_is_debug}:ORANGES_DEBUG=1>" "$<${config_is_debug}:ORANGES_RELEASE=0>"
              "$<${config_is_release}:ORANGES_DEBUG=0>" "$<${config_is_release}:ORANGES_RELEASE=1>"
              "ORANGES_BUILD_TYPE=\"$<CONFIG>\"")

set_target_properties (OrangesDefaultTarget PROPERTIES MSVC_RUNTIME_LIBRARY
                                                       "MultiThreaded$<${config_is_debug}:Debug>")

unset (config_is_debug)
unset (config_is_release)

#

# cmake-lint: disable=W0106
if (DEFINED ENV{APPLE_DEV_ID})
    set (ORANGES_IOS_DEV_TEAM_ID "$ENV{APPLE_DEV_ID}" CACHE STRING
                                                            "10-character Apple Developer ID")
endif ()

set (ios_like_systems iOS tvOS watchOS)

set (ios_like "$<IN_LIST:$<PLATFORM_ID>,${ios_like_systems}>")

unset (ios_like_systems)

set (sign_id "\"iPhone Developer\"")

set_target_properties (
    OrangesDefaultTarget
    PROPERTIES $<$<NOT:$<OR:$<PLATFORM_ID:Darwin>,${ios_like}>>:INSTALL_RPATH $ORIGIN>
               XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
               XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}"
               $<${ios_like}:ARCHIVE_OUTPUT_DIRECTORY ./>
               $<${ios_like}:XCODE_ATTRIBUTE_INSTALL_PATH $(LOCAL_APPS_DIR)>
               $<${ios_like}:XCODE_ATTRIBUTE_SKIP_INSTALL NO>
               $<${ios_like}:XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO>
               $<${ios_like}:IOS_INSTALL_COMBINED ON>
               $<${ios_like}:XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ${sign_id}>)

unset (sign_id)

if (ORANGES_IOS_DEV_TEAM_ID)
    set (dev_team_id "\"${ORANGES_IOS_DEV_TEAM_ID}\"")

    set_target_properties (
        OrangesDefaultTarget PROPERTIES $<${ios_like}:XCODE_ATTRIBUTE_DEVELOPMENT_TEAM
                                        ${dev_team_id}>)

    unset (dev_team_id)
endif ()

unset (ios_like)

if (APPLE)
    execute_process (COMMAND uname -m OUTPUT_VARIABLE osx_native_arch
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

    message (DEBUG "Mac native arch: ${osx_native_arch}")

    set_property (GLOBAL PROPERTY ORANGES_MAC_NATIVE_ARCH "${osx_native_arch}")

    if (("${osx_native_arch}" STREQUAL "arm64") AND ORANGES_MAC_UNIVERSAL_BINARY AND XCODE)

        set_target_properties (
            OrangesDefaultTarget
            PROPERTIES $<$<PLATFORM_ID:Darwin>:OSX_ARCHITECTURES x86_64$<SEMICOLON>arm64>
                       $<$<PLATFORM_ID:Darwin>:ORANGES_MAC_UNIVERSAL_BINARY TRUE>
                       $<<NOT:$<PLATFORM_ID:Darwin>>:ORANGES_MAC_UNIVERSAL_BINARY FALSE>)

        add_feature_info (ORANGES_MAC_UNIVERSAL_BINARY ON "Building universal binaries for MacOSX")

        message (VERBOSE
                 "  -- ENABLING universal binary in OrangesDefaultTarget in OrangesDefaultTarget")
    else ()
        set_target_properties (
            OrangesDefaultTarget
            PROPERTIES $<$<PLATFORM_ID:Darwin>:OSX_ARCHITECTURES ${osx_native_arch}>
                       $<$<PLATFORM_ID:Darwin>:ORANGES_MAC_UNIVERSAL_BINARY FALSE>
                       $<<NOT:$<PLATFORM_ID:Darwin>>:ORANGES_MAC_UNIVERSAL_BINARY FALSE>)

        add_feature_info (ORANGES_MAC_UNIVERSAL_BINARY OFF
                          "Not building universal binaries for MacOSX in OrangesDefaultTarget")

        message (VERBOSE "  -- DISABLING universal binary in OrangesDefaultTarget")
    endif ()

    unset (osx_native_arch)
endif ()

#

if (ORANGES_MAINTAINER_BUILD)

    include (OrangesDefaultWarnings)
    include (OrangesAllIntegrations)

    target_link_libraries (
        OrangesDefaultTarget INTERFACE $<BUILD_INTERFACE:Oranges::OrangesDefaultWarnings>
                                       $<BUILD_INTERFACE:Oranges::OrangesAllIntegrations>)

endif ()

add_library (Oranges::OrangesDefaultTarget ALIAS OrangesDefaultTarget)

#

add_library (OrangesDefaultCXXTarget INTERFACE)

set_target_properties (OrangesDefaultCXXTarget PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
                                                          CXX_EXTENSIONS OFF)

target_link_libraries (OrangesDefaultCXXTarget INTERFACE Oranges::OrangesDefaultTarget)

target_compile_features (
    OrangesDefaultCXXTarget
    INTERFACE # cmake-format: sortable
              cxx_alias_templates
              cxx_alignas
              cxx_alignof
              cxx_attributes
              cxx_auto_type
              cxx_constexpr
              cxx_decltype
              cxx_decltype_auto
              cxx_default_function_template_args
              cxx_defaulted_functions
              cxx_defaulted_move_initializers
              cxx_delegating_constructors
              cxx_deleted_functions
              cxx_explicit_conversions
              cxx_final
              cxx_func_identifier
              cxx_generalized_initializers
              cxx_generic_lambdas
              cxx_inheriting_constructors
              cxx_inline_namespaces
              cxx_lambda_init_captures
              cxx_lambdas
              cxx_noexcept
              cxx_nonstatic_member_init
              cxx_nullptr
              cxx_override
              cxx_range_for
              cxx_raw_string_literals
              cxx_relaxed_constexpr
              cxx_return_type_deduction
              cxx_rvalue_references
              cxx_sizeof_member
              cxx_static_assert
              cxx_std_20
              cxx_strong_enums
              cxx_template_template_parameters
              cxx_trailing_return_types
              cxx_user_literals
              cxx_variable_templates
              cxx_variadic_templates)

if (WIN32)
    set (intel_opts /GR /EHsc)
else ()
    set (intel_opts -fexceptions)
endif ()

target_compile_options (
    OrangesDefaultCXXTarget
    INTERFACE "$<$<CXX_COMPILER_ID:MSVC>:/EHsc>"
              "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fexceptions;-fstrict-enums;-frtti>"
              "$<$<CXX_COMPILER_ID:GNU>:-fconcepts>"
              "$<$<CXX_COMPILER_ID:Clang,AppleClang>:-fcxx-exceptions>"
              "$<${compiler_intel}:${intel_opts}>"
              $<$<CXX_COMPILER_ID:Cray>:-h
              exceptions>)

unset (intel_opts)
unset (compiler_intel)

add_library (Oranges::OrangesDefaultCXXTarget ALIAS OrangesDefaultCXXTarget)

#

install (TARGETS OrangesDefaultTarget OrangesDefaultCXXTarget EXPORT OrangesTargets)
