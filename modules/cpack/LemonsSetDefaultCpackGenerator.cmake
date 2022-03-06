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
Sets a default CPACK_GENERATOR for your system, unless one has already been explicitly specified.

Also configures some default settings for the selected generator.

## Includes:
- LinuxLSBInfo

]]

include_guard (GLOBAL)

if(NOT APPLE AND NOT WIN32)
	include (LinuxLSBInfo)
endif()

if(NOT CPACK_GENERATOR)
	include ("${CMAKE_CURRENT_LIST_DIR}/scripts/set_default_generator.cmake")

	if(ORANGES_MARK_ALL_CPACK_OPTIONS_ADVANCED)
		mark_as_advanced (FORCE CPACK_GENERATOR)
	endif()
endif()

message (VERBOSE "Using CPack generator(s): ${CPACK_GENERATOR}")
