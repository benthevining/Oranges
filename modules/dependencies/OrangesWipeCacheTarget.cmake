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

if(TARGET wipe_cache)
	message (AUTHOR_WARNING "wipe_cache target already exists!")
	return ()
endif()

if(PROJECT_IS_TOP_LEVEL)
	message (DEBUG "Oranges - adding wipe_cache target in project ${PROJECT_NAME}")
else()
	message (AUTHOR_WARNING "Creating wipe_cache target in non-top-level project ${PROJECT_NAME}!")
endif()

set (configured_script "${CMAKE_BINARY_DIR}/wipe_cache.cmake")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/wipe_cache.cmake" "${configured_script}" @ONLY)

add_custom_target (
	wipe_cache
	COMMAND "${CMAKE_COMMAND} -P ${configured_script}"
	COMMENT "Wiping cache..."
	WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
	VERBATIM USES_TERMINAL)

unset (configured_script)
