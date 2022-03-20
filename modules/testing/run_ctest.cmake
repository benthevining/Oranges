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

set (CTEST_SOURCE_DIRECTORY "@CMAKE_SOURCE_DIR@")
set (CTEST_BINARY_DIRECTORY "@CMAKE_BINARY_DIR@")

# link to coverage flags, warnings

set (CTEST_CMAKE_GENERATOR "@CMAKE_GENERATOR@")
set (CTEST_USE_LAUNCHERS 1)

set (CTEST_COVERAGE_COMMAND gcov)
set (CTEST_MEMORYCHECK_COMMAND valgrind)
set (CTEST_MEMORYCHECK_TYPE ThreadSanitizer)

# CTEST_CHECKOUT_COMMAND

ctest_start (Continuous)
ctest_configure ()
ctest_build ()
ctest_test ()
ctest_coverage ()
ctest_memcheck ()
ctest_submit ()
