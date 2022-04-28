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

cmake_minimum_required (VERSION 3.19 FATAL_ERROR)

set (oranges_root "@Oranges_SOURCE_DIR@")

# this file must exist for pip to work
file (TOUCH "@CMAKE_CURRENT_LIST_DIR@/setup.cfg")

# update this data file with the location of the installed modules
file (REMOVE "@PATHS_OUTPUT_FILE@")
file (WRITE "@PATHS_OUTPUT_FILE@" "${oranges_root}/modules")

# --prefix "@CMAKE_INSTALL_PREFIX@"

# cmake-format: off
execute_process (
	COMMAND
		python3 -m pip install .
		--log "@CMAKE_CURRENT_BINARY_DIR@/orangesHelpInstall.log"
		--compile --no-input --use-pep517
	WORKING_DIRECTORY "@CMAKE_CURRENT_LIST_DIR@"
	COMMAND_ECHO STDOUT
	COMMAND_ERROR_IS_FATAL ANY)
# cmake-format: on

file (CHMOD_RECURSE "${oranges_root}" PERMISSIONS WORLD_WRITE)
