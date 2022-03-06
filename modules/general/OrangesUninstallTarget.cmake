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

if(TARGET uninstall)
	return ()
endif()

if(PROJECT_IS_TOP_LEVEL)
	message (DEBUG "Oranges - adding uninstall target in project ${PROJECT_NAME}")
else()
	message (AUTHOR_WARNING "Creating uninstall target in non-top-level project ${PROJECT_NAME}!")
endif()

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/uninstall.cmake"
				"${CMAKE_BINARY_DIR}/uninstall.cmake" @ONLY)

add_custom_target (uninstall
				   COMMAND "${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/uninstall.cmake")
