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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

file (MAKE_DIRECTORY "@ORANGES_DOC_OUTPUT_DIR@")

find_file (original_dot_file deps_graph.dot PATHS "@CMAKE_SOURCE_DIR@" "@ORANGES_DOC_OUTPUT_DIR@"
		   NO_DEFAULT_PATH)

execute_process (COMMAND "@ORANGES_DOT@" -Tpng -o "@ORANGES_DOC_OUTPUT_DIR@/deps_graph.png"
						 "${original_dot_file}")

file (RENAME "${original_dot_file}" "@ORANGES_DOC_OUTPUT_DIR@/deps_graph.dot")
