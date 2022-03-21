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

Inclusion style: once globally

Output variables:
- LSB_DISTRIBUTOR_ID
- LSB_RELEASE
- LSB_CODENAME

]]

include_guard (GLOBAL)

include (LemonsCmakeDevTools)

oranges_file_scoped_message_context ("LinuxLSBInfo")

find_program (LSB_RELEASE_EXECUTABLE lsb_release)

mark_as_advanced (FORCE LSB_RELEASE_EXECUTABLE)

if(NOT LSB_RELEASE_EXECUTABLE)

	message (AUTHOR_WARNING "Unable to detect LSB info for your Linux distro")

	set (LSB_DISTRIBUTOR_ID "unknown" CACHE STRING "LSB distributor ID for your Linux distribution")
	set (LSB_RELEASE "unknown" CACHE STRING "LSB executable for your Linux distribution")
	set (LSB_CODENAME "unknown" CACHE STRING "LSB codename for your Linux distribution")

	return ()
endif()

execute_process (COMMAND "${LSB_RELEASE_EXECUTABLE}" -sc OUTPUT_VARIABLE LSB_CODENAME
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND "${LSB_RELEASE_EXECUTABLE}" -sr OUTPUT_VARIABLE LSB_RELEASE
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND "${LSB_RELEASE_EXECUTABLE}" -si OUTPUT_VARIABLE LSB_DISTRIBUTOR_ID
				 OUTPUT_STRIP_TRAILING_WHITESPACE)

set (LSB_DISTRIBUTOR_ID "${LSB_DISTRIBUTOR_ID}"
	 CACHE STRING "LSB distributor ID for your Linux distribution")
set (LSB_RELEASE "${LSB_RELEASE}" CACHE STRING "LSB executable for your Linux distribution")
set (LSB_CODENAME "${LSB_CODENAME}" CACHE STRING "LSB codename for your Linux distribution")

message (DEBUG "Linux ditributor ID: ${LSB_DISTRIBUTOR_ID}")
message (DEBUG "Linux release ID: ${LSB_RELEASE}")
message (DEBUG "Linux release codename: ${LSB_CODENAME}")

mark_as_advanced (FORCE LSB_DISTRIBUTOR_ID LSB_RELEASE LSB_CODENAME)
