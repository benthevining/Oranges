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

# set (CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "<10 character ID>")

set (CMAKE_SYSTEM_NAME tvOS)

set (IOS_PLATFORM_LOCATION "tvOS.platform")
set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-appletvos")

include ("${CMAKE_CURRENT_LIST_DIR}/common/ios_real_device_common.cmake")
