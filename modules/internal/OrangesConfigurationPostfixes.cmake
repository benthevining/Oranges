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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

set (ORANGES_DEBUG_POSTFIX -d CACHE STRING "Postfix to append to debug targets")
set (ORANGES_RELEASE_POSTFIX -r CACHE STRING
									  "Postfix to append to release targets")
set (ORANGES_RELWITHDEBINFO_POSTFIX -rd
	 CACHE STRING "Postfix to append to RelWithDebInfo targets")
set (ORANGES_MINSIZEREL_POSTFIX -mr
	 CACHE STRING "Postfix to append to MinSizeRel targets")

mark_as_advanced (FORCE ORANGES_DEBUG_POSTFIX ORANGES_RELEASE_POSTFIX
				  ORANGES_RELWITHDEBINFO_POSTFIX ORANGES_MINSIZEREL_POSTFIX)

set (CMAKE_DEBUG_POSTFIX "${ORANGES_DEBUG_POSTFIX}")
set (CMAKE_RELEASE_POSTFIX "${ORANGES_RELEASE_POSTFIX}")
set (CMAKE_RELWITHDEBINFO_POSTFIX "${ORANGES_RELWITHDEBINFO_POSTFIX}")
set (CMAKE_MINSIZEREL_POSTFIX "${ORANGES_MINSIZEREL_POSTFIX}")
