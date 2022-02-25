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
endif()

message (STATUS "Using CPack generator: ${CPACK_GENERATOR}")
