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

set (CMAKE_SYSTEM_NAME Windows)

set (CMAKE_CROSSCOMPILING TRUE)

find_program (CMAKE_RC_COMPILER NAMES "${COMPILER_PREFIX}-windres")
find_program (CMAKE_C_COMPILER NAMES "${COMPILER_PREFIX}-gcc")
find_program (CMAKE_CXX_COMPILER NAMES "${COMPILER_PREFIX}-g++")

set (CMAKE_FIND_ROOT_PATH "/usr/${COMPILER_PREFIX}")

set (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set (CMAKE_CROSSCOMPILING_EMULATOR wine64)
