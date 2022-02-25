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

find_program (lemonsCppCheckProgram NAMES cppcheck)

if(lemonsCppCheckProgram)
	set (CMAKE_CXX_CPPCHECK "${lemonsCppCheckProgram};--suppress=preprocessorErrorDirective"
		 CACHE INTERNAL "")
	set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE CACHE INTERNAL "")

	message (STATUS "Using cppcheck")
endif()

function(lemons_use_cppcheck_for_target target)
	if(NOT TARGET "${target}")
		message (
			FATAL_ERROR
				"Function ${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	if(lemonsCppCheckProgram)
		set_target_properties ("${target}" PROPERTIES EXPORT_COMPILE_COMMANDS ON
													  CXX_CPPCHECK "${lemonsCppCheckProgram}")
	endif()
endfunction()
