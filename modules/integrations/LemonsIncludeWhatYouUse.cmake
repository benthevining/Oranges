# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
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
