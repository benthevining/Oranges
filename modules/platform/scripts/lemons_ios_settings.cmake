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

set (ENV{MACOSX_DEPLOYMENT_TARGET} 9.3)
set (CMAKE_OSX_DEPLOYMENT_TARGET "9.3" CACHE INTERNAL "")

enable_language (OBJCXX)
enable_language (OBJC)

option (LEMONS_IOS_SIMULATOR "Build for an iOS simulator, rather than a real device" ON)

if(LEMONS_IOS_SIMULATOR)
	set (IOS_PLATFORM_LOCATION "iPhoneSimulator.platform" CACHE INTERNAL "")
	set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphonesimulator" CACHE INTERNAL "")
else()
	set (IOS_PLATFORM_LOCATION "iPhoneOS.platform" CACHE INTERNAL "")
	set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos" CACHE INTERNAL "")
endif()
