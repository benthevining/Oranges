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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsDefaultProjectSettings)
include (LemonsDefaultTarget)

add_library (LemonsDefaultStaticLibrary INTERFACE)

target_link_libraries (LemonsDefaultStaticLibrary INTERFACE LemonsDefaultTarget)

set_target_properties (LemonsDefaultStaticLibrary PROPERTIES UNITY_BUILD_MODE BATCH UNITY_BUILD ON)

#

function(lemons_configure_static_library target)

	if(NOT TARGET "${target}")
		message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${target}!")
	endif()

	target_link_libraries (${target} PUBLIC LemonsDefaultStaticLibrary)

	set_target_properties (${target} PROPERTIES VERSION "${PROJECT_VERSION}")

endfunction()
