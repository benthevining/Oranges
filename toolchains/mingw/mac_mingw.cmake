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

# Choose an appropriate compiler prefix for classical mingw32 see http://www.mingw.org/
# set(COMPILER_PREFIX "i586-mingw32msvc") for 32 or 64 bits mingw-w64 see
# http://mingw-w64.sourceforge.net/
set (COMPILER_PREFIX "x86_64-w64-mingw32")

include ("${CMAKE_CURRENT_LIST_DIR}/mingw_common.cmake")
