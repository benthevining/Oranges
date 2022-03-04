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

add_library (OrangesDefaultTarget INTERFACE)

set_target_properties (
	OrangesDefaultTarget
	PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON EXPORT_COMPILE_COMMANDS ON
			   VISIBILITY_INLINES_HIDDEN ON)

target_compile_features (OrangesDefaultTarget INTERFACE cxx_std_20)

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
	message (WARNING "Unknown compiler!")
endif()

#
# IPO

include (CheckIPOSupported)

check_ipo_supported (RESULT ipo_supported OUTPUT output)

if(ipo_supported)
	set_target_properties (OrangesDefaultTarget PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)

	message (VERBOSE "Enabling IPO")
endif()

#
# MacOS options

if(APPLE)
	if(IOS)
		set (CMAKE_OSX_DEPLOYMENT_TARGET "9.3")
	else()
		set (CMAKE_OSX_DEPLOYMENT_TARGET "10.11")
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
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "i386;x86_64")
		else()
			if(NOT LEMONS_IOS_DEV_TEAM_ID)
				message (
					SEND_ERROR
						"LEMONS_IOS_DEV_TEAM_ID must be defined in order to build for a real iOS device."
					)
			endif()

			set_target_properties (
				OrangesDefaultTarget
				PROPERTIES XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${LEMONS_IOS_DEV_TEAM_ID}"
						   XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "\"iPhone Developer\""
						   OSX_ARCHITECTURES "armv7;armv7s;arm64;i386;x86_64")
		endif()
	else()
		option (LEMONS_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)

		execute_process (COMMAND uname -m RESULT_VARIABLE result OUTPUT_VARIABLE osx_native_arch
						 OUTPUT_STRIP_TRAILING_WHITESPACE)

		if(("${osx_native_arch}" STREQUAL "arm64") AND LEMONS_MAC_UNIVERSAL_BINARY AND XCODE)
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES "x86_64;arm64")
			message (VERBOSE "Enabling universal binary")
		else()
			set_target_properties (OrangesDefaultTarget PROPERTIES OSX_ARCHITECTURES
																   "${osx_native_arch}")
		endif()
	endif()
else()
	set_target_properties (OrangesDefaultTarget PROPERTIES INSTALL_RPATH $ORIGIN)
endif()

#
# Integrations

include (OrangesAllIntegrations)

option (ORANGES_IGNORE_CCACHE "Never use ccache" OFF)

if(NOT ORANGES_IGNORE_CCACHE)
	target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesCcache)
endif()

if(PROJECT_IS_TOP_LEVEL)
	target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesAllIntegrations)
endif()

#
# Warnings

if(PROJECT_IS_TOP_LEVEL)
	target_link_libraries (OrangesDefaultTarget INTERFACE Oranges::OrangesDefaultWarnings)
endif()

#

add_library (Oranges::OrangesDefaultTarget ALIAS OrangesDefaultTarget)

install (TARGETS OrangesDefaultTarget EXPORT OrangesTargets OPTIONAL)
