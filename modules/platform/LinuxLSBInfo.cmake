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

## Include-time actions:
Sets the cache variables LSB_DISTRIBUTOR_ID, LSB_RELEASE, and LSB_CODENAME.

## Note

This module is included by Lemons by default, when Lemons is added as a subdirectory.

]]

include_guard (GLOBAL)

find_program (LSB_RELEASE_EXECUTABLE lsb_release)

mark_as_advanced (FORCE LSB_RELEASE_EXECUTABLE)

if(NOT LSB_RELEASE_EXECUTABLE)

	message (AUTHOR_WARNING "Unable to detect LSB info for your Linux distro")

	set (LSB_DISTRIBUTOR_ID "unknown" CACHE STRING "LSB distributor ID for your Linux distribution")
	set (LSB_RELEASE "unknown" CACHE STRING "LSB executable for your Linux distribution")
	set (LSB_CODENAME "unknown" CACHE STRING "LSB codename for your Linux distribution")

	return ()
endif()

execute_process (COMMAND ${LSB_RELEASE_EXECUTABLE} -sc OUTPUT_VARIABLE LSB_CODENAME
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND ${LSB_RELEASE_EXECUTABLE} -sr OUTPUT_VARIABLE LSB_RELEASE
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND ${LSB_RELEASE_EXECUTABLE} -si OUTPUT_VARIABLE LSB_DISTRIBUTOR_ID
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

set (LSB_DISTRIBUTOR_ID "${LSB_DISTRIBUTOR_ID}"
	 CACHE STRING "LSB distributor ID for your Linux distribution")
set (LSB_RELEASE "${LSB_RELEASE}" CACHE STRING "LSB executable for your Linux distribution")
set (LSB_CODENAME "${LSB_CODENAME}" CACHE STRING "LSB codename for your Linux distribution")

mark_as_advanced (FORCE LSB_DISTRIBUTOR_ID LSB_RELEASE LSB_CODENAME)
