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

include ("${CMAKE_CURRENT_LIST_DIR}/ios_common.cmake")

set (CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "<10 character ID>")

set (IOS_PLATFORM_LOCATION "iPhoneOS.platform")
set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos")

set (CMAKE_OSX_ARCHITECTURES "armv7;armv7s;arm64;i386;x86_64")
