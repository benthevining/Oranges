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
- ORANGES_IGNORE_IPO
- ORANGES_IGNORE_WARNINGS
- ORANGES_COVERAGE_FLAGS

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if(TARGET Oranges::OrangesDefaultTarget)
	return ()
endif()

include (OrangesDefaultWarnings)
include (OrangesCmakeDevTools)
include (OrangesGeneratorExpressions)
include (OrangesConfigurationPostfixes)
include (OrangesDefaultPlatformSettings)

#

option (ORANGES_IGNORE_IPO "Always ignore introprocedural optimizations" OFF)
option (ORANGES_IGNORE_WARNINGS "Ignore all warnings by default" OFF)
option (ORANGES_COVERAGE_FLAGS "Enable code coverage flags" OFF)

mark_as_advanced (FORCE ORANGES_IGNORE_IPO ORANGES_IGNORE_WARNINGS ORANGES_COVERAGE_FLAGS)

#

add_library (OrangesDefaultTarget INTERFACE)

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
	PROPERTY ORANGES_IOS_SIMULATOR
	BRIEF_DOCS "TRUE if compiling for an iOS simulator; FALSE if compiling for a real device"
	FULL_DOCS
		"TRUE if compiling for an iOS simulator; FALSE if compiling for a real device. FALSE if not cross-compiling for iOS"
	)

define_property (
	TARGET INHERITED
	PROPERTY ORANGES_MAC_UNIVERSAL_BINARY
	BRIEF_DOCS "TRUE if building a universal binary; otherwise FALSE"
	FULL_DOCS
		"When TRUE, the OSX architectures have been set to x86_64 and arm64; when false, it has been set to only this Mac's native architecture. FALSE on non-MacOSX platforms."
	)

define_property (
	TARGET INHERITED
	PROPERTY ORANGES_MAC_NATIVE_ARCH
	BRIEF_DOCS
		"String describing this Mac's native processor architecture; either x86_64 (Intel) or arm64 (M1)"
	FULL_DOCS
		"String describing this Mac's native processor architecture; either x86_64 (Intel) or arm64 (M1). Undefined on non-MacOSX platforms."
	)

#

set_target_properties (
	OrangesDefaultTarget
	PROPERTIES DEBUG_POSTFIX "${ORANGES_DEBUG_POSTFIX}"
			   RELEASE_POSTFIX "${ORANGES_RELEASE_POSTFIX}"
			   RELWITHDEBINFO_POSTFIX "${ORANGES_RELWITHDEBINFO_POSTFIX}"
			   MINSIZEREL_POSTFIX "${ORANGES_MINSIZEREL_POSTFIX}"
			   CXX_STANDARD 20
			   CXX_STANDARD_REQUIRED ON
			   EXPORT_COMPILE_COMMANDS ON
			   OPTIMIZE_DEPENDENCIES ON
			   MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>
			   $<BUILD_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE FALSE>
			   $<INSTALL_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE TRUE>)

target_compile_features (OrangesDefaultTarget INTERFACE cxx_std_20)

target_compile_definitions (OrangesDefaultTarget INTERFACE $<$<PLATFORM_ID:Windows>:NOMINMAX
														   UNICODE STRICT>)

target_compile_options (OrangesDefaultTarget
						INTERFACE $<$<CXX_COMPILER_ID:MSVC>:$<IF:$<CONFIG:Debug>,/Od /Zi,/Ox>>)

target_compile_options (OrangesDefaultTarget
						INTERFACE $<$<PLATFORM_ID:Windows>:$<IF:$<CXX_COMPILER_ID:MSVC>,/MP,/EHsc>>)

target_compile_options (OrangesDefaultTarget
						INTERFACE $<$<AND:$<CXX_COMPILER_ID:MSVC>,${GEN_ANY_REL_CONFIG}>:-GL>)

target_compile_options (
	OrangesDefaultTarget
	INTERFACE $<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang,GNU>,$<CONFIG:Debug>>:-g -O0>
			  $<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang,GNU>,${GEN_ANY_REL_CONFIG}>:-g -O3>
			  $<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang,GNU>,$<NOT:$<PLATFORM_ID:MINGW>>>:-flto>)

target_link_libraries (OrangesDefaultTarget
					   INTERFACE $<$<AND:$<CXX_COMPILER_ID:MSVC>,${GEN_ANY_REL_CONFIG}>:-LTCG>)

set_target_properties (OrangesDefaultTarget PROPERTIES $<$<NOT:$<PLATFORM_ID:Darwin>>:INSTALL_RPATH
													   $ORIGIN>)

set_target_properties (OrangesDefaultTarget
					   PROPERTIES $<$<NOT:$<PLATFORM_ID:IOS>>:ORANGES_IOS_SIMULATOR FALSE>)

set_target_properties (
	OrangesDefaultTarget
	PROPERTIES $<$<OR:$<PLATFORM_ID:IOS>,$<NOT:$<PLATFORM_ID:Darwin>>>:ORANGES_MAC_UNIVERSAL_BINARY
			   FALSE>)

#
# IPO

if(ORANGES_IGNORE_IPO)
	set_target_properties (OrangesDefaultTarget PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)
else()
	include (CheckIPOSupported)

	check_ipo_supported (RESULT ipo_supported OUTPUT output)

	if(ipo_supported)
		set_target_properties (OrangesDefaultTarget PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)

		message (VERBOSE "Enabling IPO")
	else()
		set_target_properties (OrangesDefaultTarget PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)
	endif()

	unset (output)
	unset (ipo_supported)
endif()

#
# MacOS options

if(APPLE)

	set_target_properties (
		OrangesDefaultTarget
		PROPERTIES $<$<PLATFORM_ID:IOS>:ARCHIVE_OUTPUT_DIRECTORY ./ XCODE_ATTRIBUTE_INSTALL_PATH
																	$(LOCAL_APPS_DIR)
				   XCODE_ATTRIBUTE_SKIP_INSTALL NO XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO>)

	target_compile_definitions (OrangesDefaultTarget
								INTERFACE $<$<PLATFORM_ID:Darwin>:JUCE_USE_VDSP_FRAMEWORK=1>)

	set (ios_min_deployment_target 9.3)
	set (macos_min_deployment_target 10.11)

	set_target_properties (
		OrangesDefaultTarget
		PROPERTIES
			XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
			XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET
			$<IF:$<PLATFORM_ID:IOS>,${ios_min_deployment_target},${macos_min_deployment_target}>)

	target_compile_options (
		OrangesDefaultTarget
		INTERFACE
			-mmacosx-version-min=$<IF:$<PLATFORM_ID:IOS>,${ios_min_deployment_target},${macos_min_deployment_target}>
		)

	target_link_options (
		OrangesDefaultTarget
		INTERFACE
		-mmacosx-version-min=$<IF:$<PLATFORM_ID:IOS>,${ios_min_deployment_target},${macos_min_deployment_target}>
		)

	unset (ios_min_deployment_target)
	unset (macos_min_deployment_target)

	if(IOS)
		if(LEMONS_IOS_COMBINED)
			set (ORANGES_IOS_SIMULATOR ON)
		endif()

		if(ORANGES_IOS_SIMULATOR OR LEMONS_IOS_COMBINED)
			set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_IOS_SIMULATOR TRUE)
		else()
			set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_IOS_SIMULATOR FALSE)
		endif()

		if(ORANGES_IOS_SIMULATOR AND NOT LEMONS_IOS_COMBINED)
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "i386;x86_64")
		else()
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES
																   "armv7;armv7s;arm64;i386;x86_64")

			# cmake-lint: disable=W0106
			if(DEFINED ENV{APPLE_DEV_ID})
				set (ORANGES_IOS_DEV_TEAM_ID "$ENV{APPLE_DEV_ID}"
					 CACHE STRING "10-character Apple Developer ID")
			endif()

			if(NOT ORANGES_IOS_DEV_TEAM_ID)
				message (
					SEND_ERROR
						"ORANGES_IOS_DEV_TEAM_ID must be defined in order to build for a real iOS device."
					)
			endif()

			set_target_properties (
				OrangesDefaultTarget
				PROPERTIES XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${ORANGES_IOS_DEV_TEAM_ID}"
						   XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "\"iPhone Developer\"")
		endif()

		if(LEMONS_IOS_COMBINED)
			set_target_properties (OrangesDefaultTarget PROPERTIES IOS_INSTALL_COMBINED ON)
		endif()
	else()
		execute_process (COMMAND uname -m RESULT_VARIABLE result OUTPUT_VARIABLE osx_native_arch
						 OUTPUT_STRIP_TRAILING_WHITESPACE)

		message (DEBUG "Mac native arch: ${osx_native_arch}")

		set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_MAC_NATIVE_ARCH
															   "${osx_native_arch}")

		if(("${osx_native_arch}" STREQUAL "arm64") AND ORANGES_MAC_UNIVERSAL_BINARY AND XCODE)
			set_target_properties (
				OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "x86_64;arm64"
												ORANGES_MAC_UNIVERSAL_BINARY TRUE)

			message (VERBOSE "Enabling universal binary")
		else()
			set_target_properties (
				OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "${osx_native_arch}"
												ORANGES_MAC_UNIVERSAL_BINARY FALSE)
		endif()

		unset (osx_native_arch)
	endif()
endif()

#
# Integrations

include (OrangesAllIntegrations)

target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesAllIntegrations)

#
# Warnings

if(PROJECT_IS_TOP_LEVEL)
	if(NOT ORANGES_IGNORE_WARNINGS)
		target_link_libraries (OrangesDefaultTarget
							   INTERFACE $<TARGET_NAME_IF_EXISTS:Oranges::OrangesDefaultWarnings>)
	endif()
endif()

#
# Coverage flags

if(ORANGES_COVERAGE_FLAGS)
	include (OrangesCoverageFlags)

	target_link_libraries (OrangesDefaultTarget
						   INTERFACE $<TARGET_NAME_IF_EXISTS:Oranges::OrangesCoverageFlags>)

	message (VERBOSE "Enabling coverage flags for default target")
endif()

#

oranges_export_alias_target (OrangesDefaultTarget Oranges)

oranges_install_targets (TARGETS OrangesDefaultTarget EXPORT OrangesTargets)
