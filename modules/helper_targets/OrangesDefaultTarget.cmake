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
- ORANGES_IOS_SIMULATOR (iOS only)
- LEMONS_IOS_COMBINED (iOS only)
- ORANGES_MAC_UNIVERSAL_BINARY (macOS only)

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- APPLE_DEV_ID

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

#

option (ORANGES_IGNORE_IPO "Always ignore introprocedural optimizations" OFF)
option (ORANGES_IGNORE_WARNINGS "Ignore all warnings by default" OFF)
option (ORANGES_COVERAGE_FLAGS "Enable code coverage flags" OFF)

if(APPLE)
	if(IOS)
		option (ORANGES_IOS_SIMULATOR "Build for an iOS simulator, rather than a real device" ON)
		option (LEMONS_IOS_COMBINED "Build for both the iOS simulator and a real device" OFF)

		# if(LEMONS_IOS_COMBINED) set (ORANGES_IOS_SIMULATOR ON) endif()

		set (CMAKE_OSX_DEPLOYMENT_TARGET 9.3 CACHE STRING "Minimum OSX version to build for")

		enable_language (OBJCXX)
		enable_language (OBJC)
	else()
		option (ORANGES_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)

		set (CMAKE_OSX_DEPLOYMENT_TARGET 10.11 CACHE STRING "Minimum OSX version to build for")
	endif()
else()
	set (CMAKE_INSTALL_RPATH $ORIGIN)

	if(UNIX AND NOT WIN32)
		set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
		set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")

		include (LinuxLSBInfo)
	endif()
endif()

mark_as_advanced (
	FORCE
	ORANGES_IGNORE_IPO
	ORANGES_IGNORE_WARNINGS
	ORANGES_COVERAGE_FLAGS
	ORANGES_IOS_SIMULATOR
	LEMONS_IOS_COMBINED
	ORANGES_MAC_UNIVERSAL_BINARY)

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

add_library (OrangesDefaultTarget INTERFACE)

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

# suppress "unknown pragma" warnings in MSVC
target_compile_options (OrangesDefaultTarget INTERFACE $<$<CXX_COMPILER_ID:MSVC>:/wd4068>)

target_compile_features (OrangesDefaultTarget INTERFACE cxx_std_20)

target_compile_definitions (OrangesDefaultTarget INTERFACE $<$<PLATFORM_ID:Windows>:NOMINMAX
														   UNICODE STRICT>)

target_compile_options (OrangesDefaultTarget
						INTERFACE $<$<CXX_COMPILER_ID:MSVC>:$<IF:$<CONFIG:Debug>,/Od /Zi,/Ox>>)

target_compile_options (
	OrangesDefaultTarget
	INTERFACE
		$<$<PLATFORM_ID:Windows>:$<IF:$<CXX_COMPILER_ID:MSVC>,/MP,$<$<NOT:$<CXX_COMPILER_ID:Clang>>:/EHsc>>>
	)

target_compile_options (OrangesDefaultTarget
						INTERFACE $<$<AND:$<CXX_COMPILER_ID:MSVC>,${GEN_ANY_REL_CONFIG}>:-GL>)

target_compile_options (
	OrangesDefaultTarget
	INTERFACE $<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang,GNU>,$<CONFIG:Debug>>:-g -O0>
			  $<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang,GNU>,${GEN_ANY_REL_CONFIG}>:-g -O3>
			  $<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang,GNU>,$<NOT:$<PLATFORM_ID:MINGW>>>:-flto>)

target_link_libraries (OrangesDefaultTarget
					   INTERFACE $<$<AND:$<CXX_COMPILER_ID:MSVC>,${GEN_ANY_REL_CONFIG}>:-LTCG>)

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
	target_compile_definitions (OrangesDefaultTarget INTERFACE JUCE_USE_VDSP_FRAMEWORK=1)

	set_target_properties (
		OrangesDefaultTarget
		PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
				   XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}")

	if(IOS)
		set_target_properties (
			OrangesDefaultTarget
			PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ./ XCODE_ATTRIBUTE_INSTALL_PATH "$(LOCAL_APPS_DIR)"
					   XCODE_ATTRIBUTE_SKIP_INSTALL NO XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO)

		if(ORANGES_IOS_SIMULATOR)
			set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_IOS_SIMULATOR TRUE)
		else()
			set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_IOS_SIMULATOR FALSE)
		endif()

		if(ORANGES_IOS_SIMULATOR AND NOT LEMONS_IOS_COMBINED)
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "i386;x86_64")
		else()
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES
																   "armv7;armv7s;arm64;i386;x86_64")
		endif()

		if(NOT ORANGES_IOS_SIMULATOR)
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
		else()
			set_target_properties (OrangesDefaultTarget PROPERTIES IOS_INSTALL_COMBINED OFF)
		endif()

	else() # MacOS

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

else() # not Apple platform
	set_target_properties (OrangesDefaultTarget PROPERTIES INSTALL_RPATH $ORIGIN)
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

install (TARGETS OrangesDefaultTarget EXPORT OrangesTargets)

add_library (Oranges::OrangesDefaultTarget ALIAS OrangesDefaultTarget)
