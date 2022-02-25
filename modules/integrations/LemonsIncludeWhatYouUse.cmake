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

find_program (lemons_iwyu_path NAMES include-what-you-use iwyu)

if(lemons_iwyu_path)
	set (CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${lemons_iwyu_path}" CACHE INTERNAL "")

	message (STATUS "Enabled include-what-you-use")
endif()

function(lemons_use_iwyu_for_target target)

	if(NOT TARGET "${target}")
		message (
			FATAL_ERROR
				"Function ${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	if(lemons_iwyu_path)
		set_target_properties ("${target}" PROPERTIES CXX_INCLUDE_WHAT_YOU_USE
													  "${lemons_iwyu_path}")
	endif()
endfunction()
