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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesDefaultWarnings)
include (LemonsCmakeDevTools)

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
	PROPERTY ORANGES_PROJECT_IS_TOP_LEVEL
	BRIEF_DOCS
		"Boolean indicating whether the project that created this target is the top-level CMake project"
	FULL_DOCS
		"Boolean indicating whether the project that created this target is the top-level CMake project"
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
		"When TRUE, the OSX architectures have been set to x86_64 and arm64; when false, it has been set to only this Mac's native architecture, ${osx_native_arch}. FALSE on non-MacOSX platforms."
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
	PROPERTIES DEBUG_POSTFIX -d
			   CXX_STANDARD 20
			   CXX_STANDARD_REQUIRED ON
			   EXPORT_COMPILE_COMMANDS ON
			   $<BUILD_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE FALSE>
			   $<INSTALL_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE TRUE>)

target_compile_features (OrangesDefaultTarget INTERFACE cxx_std_20)

if(PROJECT_IS_TOP_LEVEL)
	set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_PROJECT_IS_TOP_LEVEL TRUE)
else()
	set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_PROJECT_IS_TOP_LEVEL FALSE)
endif()

if(NOT IOS)
	set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_IOS_SIMULATOR FALSE)
endif()

if(IOS OR NOT APPLE)
	set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_MAC_UNIVERSAL_BINARY FALSE)
endif()

if(WIN32)
	target_compile_definitions (OrangesDefaultTarget INTERFACE NOMINMAX UNICODE STRICT)
endif()

if((CMAKE_CXX_COMPILER_ID MATCHES "MSVC") OR (CMAKE_CXX_COMPILER_FRONTEND_VARIANT MATCHES "MSVC"))

	# config flags
	target_compile_options (
		OrangesDefaultTarget INTERFACE $<IF:$<CONFIG:Debug>,/Od /Zi,/Ox>
									   $<$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">:/MP> /EHsc)

	# LTO
	target_compile_options (
		OrangesDefaultTarget
		INTERFACE $<$<CONFIG:Release>:$<IF:$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">,-GL,-flto>>
		)

	target_link_libraries (
		OrangesDefaultTarget
		INTERFACE $<$<CONFIG:Release>:$<$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">:-LTCG>>)

	set_target_properties (OrangesDefaultTarget PROPERTIES MSVC_RUNTIME_LIBRARY
														   "MultiThreaded$<$<CONFIG:Debug>:Debug>")

elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang|GNU")

	# config flags
	target_compile_options (OrangesDefaultTarget INTERFACE $<$<CONFIG:Debug>:-g -O0>
														   $<$<CONFIG:Release>:-O3>)

	# LTO
	if(NOT MINGW)
		target_compile_options (OrangesDefaultTarget INTERFACE $<$<CONFIG:Release>:-flto>)
		target_link_libraries (OrangesDefaultTarget INTERFACE $<$<CONFIG:Release>:-flto>)
	endif()

else()
	message (DEBUG "Unknown compiler!")
endif()

#
# IPO

option (ORANGES_IGNORE_IPO "Always ignore introprocedural optimizations" OFF)

mark_as_advanced (ORANGES_IGNORE_IPO FORCE)

if(NOT ORANGES_IGNORE_IPO)
	include (CheckIPOSupported)

	check_ipo_supported (RESULT ipo_supported OUTPUT output)

	if(ipo_supported)
		set_target_properties (OrangesDefaultTarget PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)

		message (VERBOSE "Enabling IPO")
	endif()
endif()

#
# MacOS options

if(APPLE)
	if(IOS)
		set (CMAKE_OSX_DEPLOYMENT_TARGET "9.3" CACHE STRING "Minimum iOS deployment target")
	else()
		set (CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Minimum MacOS deployment target")
	endif()

	set_target_properties (
		OrangesDefaultTarget
		PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
				   XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}")

	target_compile_definitions (OrangesDefaultTarget INTERFACE JUCE_USE_VDSP_FRAMEWORK=1)

	target_compile_options (OrangesDefaultTarget
							INTERFACE "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")

	target_link_options (OrangesDefaultTarget INTERFACE
						 "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")

	if(IOS)

		set_target_properties (
			OrangesDefaultTarget
			PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "./" XCODE_ATTRIBUTE_INSTALL_PATH
													 "$(LOCAL_APPS_DIR)"
					   XCODE_ATTRIBUTE_SKIP_INSTALL NO XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO)

		option (LEMONS_IOS_SIMULATOR "Build for an iOS simulator, rather than a real device" ON)

		if(LEMONS_IOS_SIMULATOR)
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "i386;x86_64"
																   ORANGES_IOS_SIMULATOR TRUE)
		else()

			set (ORANGES_IOS_DEV_TEAM_ID "" CACHE STRING "10-character Apple Developer ID")

			if(NOT ORANGES_IOS_DEV_TEAM_ID)
				message (
					SEND_ERROR
						"ORANGES_IOS_DEV_TEAM_ID must be defined in order to build for a real iOS device."
					)
			endif()

			set_target_properties (
				OrangesDefaultTarget
				PROPERTIES XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${ORANGES_IOS_DEV_TEAM_ID}"
						   XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "\"iPhone Developer\""
						   OSX_ARCHITECTURES "armv7;armv7s;arm64;i386;x86_64"
						   ORANGES_IOS_SIMULATOR FALSE)
		endif()

	else() # if (IOS)

		option (ORANGES_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)

		execute_process (COMMAND uname -m RESULT_VARIABLE result OUTPUT_VARIABLE osx_native_arch
						 OUTPUT_STRIP_TRAILING_WHITESPACE)

		set (osx_native_arch "${osx_native_arch}" CACHE INTERNAL "")

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
	endif()
else()
	set_target_properties (OrangesDefaultTarget PROPERTIES INSTALL_RPATH $ORIGIN)
endif()

#
# Integrations

include (OrangesAllIntegrations)

option (ORANGES_IGNORE_CCACHE "Never use ccache" OFF)

mark_as_advanced (ORANGES_IGNORE_CCACHE FORCE)

if((TARGET Oranges::OrangesCcache) AND (NOT ORANGES_IGNORE_CCACHE))
	target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesCcache)
else()
	set_target_properties (OrangesDefaultTarget PROPERTIES ORANGES_USING_CCACHE FALSE)
endif()

if(PROJECT_IS_TOP_LEVEL)

	option (ORANGES_IGNORE_INTEGRATIONS "Ignore all static analysis integrations by default" OFF)

	mark_as_advanced (ORANGES_IGNORE_INTEGRATIONS FORCE)

	if(NOT ORANGES_IGNORE_INTEGRATIONS)
		target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesAllIntegrations)
	endif()
endif()

#
# Warnings

if(PROJECT_IS_TOP_LEVEL)

	option (ORANGES_IGNORE_WARNINGS "Ignore all warnings by default" OFF)

	mark_as_advanced (ORANGES_IGNORE_WARNINGS FORCE)

	if(NOT ORANGES_IGNORE_WARNINGS)
		target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesDefaultWarnings)
	endif()
endif()

#
# Coverage flags

option (ORANGES_COVERAGE_FLAGS "Enable code coverage flags" OFF)

if(ORANGES_COVERAGE_FLAGS)
	include (OrangesCoverageFlags)

	if(TARGET Oranges::OrangesCoverageFlags)
		target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesCoverageFlags)
		message (VERBOSE "Enabling coverage flags for default target")
	endif()
endif()

#

oranges_export_alias_target (OrangesDefaultTarget Oranges)

oranges_install_targets (TARGETS OrangesDefaultTarget EXPORT OrangesTargets)
