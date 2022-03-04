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

set (CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Minimum MacOS deployment target")

set (LEMONS_MAC_SDK_VERSION "10.13" CACHE STRING "Mac SDK version")

mark_as_advanced (FORCE CMAKE_OSX_DEPLOYMENT_TARGET LEMONS_MAC_SDK_VERSION)

find_path (
	MAC_SDK_DIR "MacOSX${LEMONS_MAC_SDK_VERSION}.sdk"
	PATHS "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs"
	DOC "Path to the MacOS SDK")

mark_as_advanced (FORCE MAC_SDK_DIR)

if(MAC_SDK_DIR AND IS_DIRECTORY ${MAC_SDK_DIR})
	set (CMAKE_OSX_SYSROOT ${MAC_SDK_DIR})
else()
	message (DEBUG "Mac SDK dir ${MAC_SDK_DIR} doesn't exist!")
endif()
