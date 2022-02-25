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

## Include-time actions:
Sets the cache variables LSB_DISTRIBUTOR_ID, LSB_RELEASE, and LSB_CODENAME.

## Note

This module is included by Lemons by default, when Lemons is added as a subdirectory.

]]

include_guard (GLOBAL)

set (LSB_DISTRIBUTOR_ID "unknown" CACHE INTERNAL "")
set (LSB_RELEASE "unknown" CACHE INTERNAL "")
set (LSB_CODENAME "unknown" CACHE INTERNAL "")

find_program (LSB_RELEASE_EXECUTABLE lsb_release)

if(NOT LSB_RELEASE_EXECUTABLE)
	message (AUTHOR_WARNING "Unable to detect LSB info for your Linux distro")
	return ()
endif()

execute_process (COMMAND ${LSB_RELEASE_EXECUTABLE} -sc OUTPUT_VARIABLE LSB_CODENAME
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND ${LSB_RELEASE_EXECUTABLE} -sr OUTPUT_VARIABLE LSB_RELEASE
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND ${LSB_RELEASE_EXECUTABLE} -si OUTPUT_VARIABLE LSB_DISTRIBUTOR_ID
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

set (LSB_DISTRIBUTOR_ID "${LSB_DISTRIBUTOR_ID}" CACHE INTERNAL "")
set (LSB_RELEASE "${LSB_RELEASE}" CACHE INTERNAL "")
set (LSB_CODENAME "${LSB_CODENAME}" CACHE INTERNAL "")
