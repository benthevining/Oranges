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
		include ("${CMAKE_CURRENT_LIST_DIR}/scripts/lemons_ios_settings.cmake")
	else()
		include ("${CMAKE_CURRENT_LIST_DIR}/scripts/lemons_macos_settings.cmake")
	endif()
else()
	set (CMAKE_INSTALL_RPATH $ORIGIN CACHE INTERNAL "")

	if(WIN32)
		include ("${CMAKE_CURRENT_LIST_DIR}/scripts/lemons_windows_settings.cmake")
	else()
		include ("${CMAKE_CURRENT_LIST_DIR}/scripts/lemons_linux_settings.cmake")
		include (LinuxLSBInfo)
	endif()
endif()
