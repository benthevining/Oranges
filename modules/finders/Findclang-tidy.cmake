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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)

set_package_properties (clang-tidy PROPERTIES URL "https://clang.llvm.org/extra/clang-tidy/"
						DESCRIPTION "C++ code linter")

set (clang-tidy_FOUND FALSE)

find_program (ORANGES_CLANG_TIDY NAMES clang-tidy)

mark_as_advanced (FORCE ORANGES_CLANG_TIDY)

if(NOT ORANGES_CLANG_TIDY)
	if(clang-tidy_FIND_REQUIRED)
		message (FATAL_ERROR "clang-tidy program cannot be found!")
	endif()

	return ()
endif()

add_executable (clang-tidy IMPORTED GLOBAL)

set_target_properties (clang-tidy PROPERTIES IMPORTED_LOCATION "${ORANGES_CLANG_TIDY}")

add_executable (Clang::clang-tidy ALIAS clang-tidy)

set (clang-tidy_FOUND TRUE)
