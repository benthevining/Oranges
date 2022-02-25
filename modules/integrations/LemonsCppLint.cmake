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

find_program (lemonsCppLintProgram NAMES cpplint)

if(lemonsCppLintProgram)
	set (CMAKE_CXX_CPPLINT "${lemonsCppLintProgram}" CACHE INTERNAL "")
	set (CMAKE_C_CPPLINT "${lemonsCppLintProgram}" CACHE INTERNAL "")

	message (STATUS "Using cpplint")
endif()

function(lemons_use_cpplint_for_target target)

	if(NOT TARGET "${target}")
		message (
			FATAL_ERROR
				"Function ${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	if(lemonsCppLintProgram)
		set_target_properties ("${target}" PROPERTIES CXX_CPPLINT "${lemonsCppLintProgram}"
													  C_CPPLINT "${lemonsCppLintProgram}")
	endif()
endfunction()
