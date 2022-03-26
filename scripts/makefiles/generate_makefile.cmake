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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

if(NOT PROJECT_NAME)
	message (FATAL_ERROR "Required input variable PROJECT_NAME is not defined!")
endif()

if(OUT_FILE)
	cmake_path (IS_ABSOLUTE OUT_FILE is_abs_path)

	if(NOT is_abs_path)
		set (OUT_FILE "${CMAKE_CURRENT_LIST_DIR}/${OUT_FILE}")
	endif()
else()
	set (OUT_FILE "${CMAKE_CURRENT_LIST_DIR}/Makefile")
endif()

if(EXISTS "${OUT_FILE}")
	file (REMOVE "${OUT_FILE}")
endif()

#

set (input_file "${CMAKE_CURRENT_LIST_DIR}/Makefile.in")

if(NOT EXISTS "${input_file}")
	file (
		DOWNLOAD
		"https://raw.githubusercontent.com/benthevining/Oranges/main/scripts/makefiles/Makefile.in"
		"${input_file}")
endif()

configure_file ("${input_file}" "${OUT_FILE}" @ONLY)
