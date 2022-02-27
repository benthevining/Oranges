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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsDefaultPlatformSettings)

option (LEMONS_ENABLE_INTEGRATIONS "Enable all available integrations by default" OFF)

if(LEMONS_ENABLE_INTEGRATIONS)
	include (LemonsAllIntegrations)
endif()

set_property (GLOBAL PROPERTY REPORT_UNDEFINED_PROPERTIES
							  "${PROJECT_SOURCE_DIR}/logs/undefined_properties.log")

set (CMAKE_CXX_VISIBILITY_PRESET hidden CACHE INTERNAL "")

set_property (GLOBAL PROPERTY USE_FOLDERS YES)
set_property (GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "Targets")

set (CMAKE_SUPPRESS_REGENERATION TRUE CACHE INTERNAL "")

if(NOT DEFINED ENV{CMAKE_INSTALL_MODE})
	set (ENV{CMAKE_INSTALL_MODE} ABS_SYMLINK_OR_COPY)
endif()

#

include (LemonsDefaultTarget)

#

function(lemons_sort_target_sources target root_dir)

	if(NOT IS_DIRECTORY "${root_dir}")
		message (FATAL_ERROR "Source grouping root directory ${root_dir} does not exist!")
	endif()

	if(NOT TARGET "${target}")
		message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	get_target_property (target_sources "${target}" SOURCES)

	if(NOT target_sources)
		unset (target_sources)
	endif()

	get_target_property (target_interface_sources "${target}" INTERFACE_SOURCES)

	if(target_interface_sources)
		list (APPEND target_sources ${target_interface_sources})
	endif()

	if(NOT target_sources)
		message (WARNING "Error sorting sources for target ${target}")
		return ()
	endif()

	source_group (TREE "${root_dir}" FILES "${target_sources}")

endfunction()

#

function(lemons_enable_coverage_flags target)

	if(NOT TARGET "${target}")
		message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
		message (
			WARNING
				"Coverage flags are not supported with your current compiler: ${CMAKE_CXX_COMPILER_ID}"
			)
		return ()
	endif()

	target_compile_options (
		${target}
		PUBLIC -O0 # no optimization
			   -g # generate debug info
			   --coverage # sets all required flags
		)

	target_link_options (${target} PUBLIC --coverage)

endfunction()
