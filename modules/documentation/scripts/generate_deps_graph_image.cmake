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

file (MAKE_DIRECTORY "@ORANGES_ARG_OUTPUT_DIR@") # ORANGES_ARG_OUTPUT_DIR

# look in ORANGES_ARG_SOURCE_DIR, ORANGES_ARG_BINARY_DIR and ORANGES_ARG_OUTPUT_DIR
find_file (
    original_dot_file deps_graph.dot PATHS "@ORANGES_ARG_SOURCE_DIR@" "@ORANGES_ARG_BINARY_DIR@"
                                           "@ORANGES_ARG_OUTPUT_DIR@" NO_DEFAULT_PATH)

if (NOT original_dot_file OR NOT EXISTS "${original_dot_file}")
    message (
        WARNING ".dot input file ${original_dot_file} does not exist, image cannot be generated")

    return ()
endif ()

set (output_graph "@ORANGES_ARG_OUTPUT_DIR@/deps_graph.png")

execute_process (
    COMMAND "@PROGRAM_DOT@" -Tpng -o "${output_graph}" "${original_dot_file}"
    WORKING_DIRECTORY "@ORANGES_ARG_OUTPUT_DIR@" COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)
