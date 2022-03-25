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

LemonsDefaultPlatformSettings
-------------------------

Default settings and configuration for a CMake build on the OS you're currently running.


Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ORANGES_IOS_SIMULATOR (iOS only)
- LEMONS_IOS_COMBINED (iOS only)
- ORANGES_MAC_UNIVERSAL_BINARY (macOS only)

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

#

if(IOS)
	option (ORANGES_IOS_SIMULATOR "Build for an iOS simulator, rather than a real device" ON)
	option (LEMONS_IOS_COMBINED "Build for both the iOS simulator and a real device" OFF)
elseif(APPLE)
	option (ORANGES_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)
endif()

mark_as_advanced (FORCE ORANGES_IOS_SIMULATOR LEMONS_IOS_COMBINED ORANGES_MAC_UNIVERSAL_BINARY)

#

if(APPLE)
	if(IOS)
		set (CMAKE_OSX_DEPLOYMENT_TARGET "9.3" CACHE STRING "Minimum iOS deployment target")

		enable_language (OBJCXX)
		enable_language (OBJC)

		if(ORANGES_IOS_SIMULATOR)
			set (IOS_PLATFORM_LOCATION "iPhoneSimulator.platform")
			set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphonesimulator")
		else()
			set (IOS_PLATFORM_LOCATION "iPhoneOS.platform")
			set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos")
		endif()
	else()
		set (CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Minimum MacOS deployment target")
	endif()

	mark_as_advanced (CMAKE_OSX_DEPLOYMENT_TARGET FORCE)
else()
	set (CMAKE_INSTALL_RPATH $ORIGIN)

	if(UNIX AND NOT WIN32)
		# Linux settings
		set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
		set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")

		include (LinuxLSBInfo)
	endif()
endif()
