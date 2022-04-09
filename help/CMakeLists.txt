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

cmake_minimum_required (VERSION 3.13 FATAL_ERROR)

project (OrangesHelp DESCRIPTION "Oranges CLI help" LANGUAGES NONE
		 HOMEPAGE_URL "www.github.com/benthevining/Oranges")

if(PROJECT_IS_TOP_LEVEL)
	enable_language (CXX)

	set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

	include ("${ORANGES_ROOT_DIR}/scripts/OrangesMacros.cmake")
endif()

set_directory_properties (
	PROPERTIES
		ADDITIONAL_CLEAN_FILES
		"${CMAKE_CURRENT_LIST_DIR}/__pycache__;${CMAKE_CURRENT_LIST_DIR}/oranges_help/__pycache__")

add_custom_target (
	OrangesHelp
	COMMAND python3 setup.py build
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
	COMMENT "Building help Python package..."
	VERBATIM USES_TERMINAL)

install (CODE "execute_process (COMMAND python3 setup.py install
								WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
								COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)")

add_custom_target (
	OrangesHelp_wheel
	COMMAND python3 -m pip wheel .
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
	COMMENT "Building Python wheel package..."
	VERBATIM USES_TERMINAL)
