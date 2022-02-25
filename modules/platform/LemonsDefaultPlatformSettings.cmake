# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
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

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
	if(NOT (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10.0.0"))
		message (SEND_ERROR "C++ concepts are not available in GCC versions before 10.0!")
	endif()
endif()
