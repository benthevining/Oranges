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

find_program (lemonsClangTidyProgram NAMES clang-tidy)

if(lemonsClangTidyProgram)
	set (CMAKE_CXX_CLANG_TIDY "${lemonsClangTidyProgram}" CACHE INTERNAL "")
	set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE CACHE INTERNAL "")

	message (STATUS "Using clang-tidy")
endif()

function(lemons_use_clang_tidy_for_target target)

	if(NOT TARGET "${target}")
		message (
			FATAL_ERROR
				"Function ${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	if(lemonsClangTidyProgram)
		set_target_properties ("${target}" PROPERTIES EXPORT_COMPILE_COMMANDS ON
													  CXX_CLANG_TIDY "${lemonsClangTidyProgram}")
	endif()
endfunction()
