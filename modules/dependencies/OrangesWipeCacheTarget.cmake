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

#[=======================================================================[.rst:

OrangesWipeCacheTarget
-------------------------

When this module is included, it creates a target that wipes all persistent caches of downloaded dependencies.

Inclusion style: Once globally, preferably from the top-level project


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- wipe_cache

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("OrangesWipeCacheTarget")

if(TARGET wipe_cache)
	message (AUTHOR_WARNING "wipe_cache target already exists!")
	return ()
endif()

include (OrangesSetUpCache)

if(PROJECT_IS_TOP_LEVEL)
	message (DEBUG "Oranges - adding wipe_cache target in project ${PROJECT_NAME}")
else()
	message (AUTHOR_WARNING "Creating wipe_cache target in non-top-level project ${PROJECT_NAME}!")
endif()

set (configured_script "${CMAKE_BINARY_DIR}/wipe_cache.cmake")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/wipe_cache.cmake" "${configured_script}" @ONLY)

find_program (PROGRAM_SUDO sudo)

mark_as_advanced (FORCE PROGRAM_SUDO)

add_custom_target (
	wipe_cache
	COMMAND "${PROGRAM_SUDO}" "${CMAKE_COMMAND} -P ${configured_script}"
	COMMENT "Wiping cache..."
	WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
	VERBATIM USES_TERMINAL)

unset (configured_script)
