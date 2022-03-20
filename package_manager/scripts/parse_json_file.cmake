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

#[[

Inputs:
- JSON_FILE

Outputs:
- json_file_text -- with all includes resolved and the $fileDir macro expanded
- PROJECT_NAME
- PROJECT_ROOT
- IGNORE_ORANGES
- GIT_ALL_FULL, GIT_OPTIONS, GIT_STRATEGY
- FILE_DOWNLOAD_TIMEOUT


JSON MACROS TO ADD:
- $projectName
- $projectRoot
- $parentFile (path to file that included this one)

]]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

function(_oranges_process_json_file_macros json_file_path inText outVar)

	cmake_path (GET json_file_path ROOT_DIRECTORY JSON_FILE_DIR)

	string (REPLACE "$fileDir" "${JSON_FILE_DIR}" inText "${inText}")

	set (${outVar} "${inText}" PARENT_SCOPE)

endfunction()

#

if(NOT JSON_FILE)
	message (FATAL_ERROR "JSON_FILE variable must be defined!")
endif()

if(NOT EXISTS "${JSON_FILE}")
	message (FATAL_ERROR "JSON file ${JSON_FILE} does not exist!")
endif()

file (READ "${JSON_FILE}" json_file_text)

_oranges_process_json_file_macros ("${JSON_FILE}" "${json_file_text}" json_file_text)

# resolve all includes (recursively)

if(NOT PROJECT_ROOT)
	cmake_path (GET JSON_FILE ROOT_DIRECTORY JSON_FILE_DIR)
	set (PROJECT_ROOT "${JSON_FILE_DIR}")
endif()
