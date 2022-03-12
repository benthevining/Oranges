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

#[[
Default settings and configuration for a CMake build on the OS you're currently running.

## Include-time actions:
Sets appropriate platform-specific settings for the current build.

## Function:

### lemons_set_default_macos_options
```
lemons_set_default_macos_options (<target>)
```
Sets default Apple-only options for the given target.
Does nothing on non-Apple platforms.


## Note

This module is included by Lemons by default, when Lemons is added as a subdirectory.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

if(APPLE)
	if(IOS)
		set (CMAKE_OSX_DEPLOYMENT_TARGET "9.3" CACHE STRING "Minimum iOS deployment target")

		enable_language (OBJCXX)
		enable_language (OBJC)

		option (ORANGES_IOS_SIMULATOR "Build for an iOS simulator, rather than a real device" ON)

		mark_as_advanced (FORCE ORANGES_IOS_SIMULATOR)

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
