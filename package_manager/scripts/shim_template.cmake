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

set (FETCHCONTENT_BASE_DIR "@CACHE@")
set (ORANGES_FILE_DOWNLOAD_CACHE "@CACHE@")

# include Oranges
if(NOT "@IGNORE_ORANGES@") # if(NOT "@IGNORE_ORANGES@")
	add_subdirectory ("@ORANGES_ROOT_DIR@" "${CMAKE_CURRENT_BINARY_DIR}/Oranges")

	list (APPEND CMAKE_MODULE_PATH "${ORANGES_CMAKE_MODULE_PATH}")
endif()

list (APPEND CMAKE_MODULE_PATH "@GENERATED_FIND_MODULES@")
list (APPEND CMAKE_PREFIX_PATH "@CACHE@")
