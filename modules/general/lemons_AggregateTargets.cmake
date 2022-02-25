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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

option (LEMONS_CREATE_AGGREGATE_TARGETS
		"Generate ALL_APPS and ALL_PLUGINS targets, populated accordingly" ON)
mark_as_advanced (LEMONS_CREATE_AGGREGATE_TARGETS)

#

function(_lemons_add_to_all_apps_target target)

	if(NOT LEMONS_CREATE_AGGREGATE_TARGETS)
		return ()
	endif()

	if(NOT TARGET LEMONS_ALL_APPS)
		message (DEBUG "Creating aggregate target LEMONS_ALL_APPS...")
		add_custom_target (LEMONS_ALL_APPS COMMENT "Building all apps...")
	endif()

	add_dependencies (LEMONS_ALL_APPS ${target})

endfunction()

#

function(_lemons_add_to_all_plugins_target target)

	if(NOT LEMONS_CREATE_AGGREGATE_TARGETS)
		return ()
	endif()

	if(NOT TARGET LEMONS_ALL_PLUGINS)
		message (DEBUG "Creating aggregate target LEMONS_ALL_PLUGINS...")
		add_custom_target (LEMONS_ALL_PLUGINS COMMENT "Building all plugins...")
	endif()

	add_dependencies (LEMONS_ALL_PLUGINS "${target}_All")

	set (stdaln_target "${target}_Standalone")

	if(TARGET ${stdaln_target})
		message (DEBUG "Adding standalone plugin to all apps target...")
		_lemons_add_to_all_apps_target (${stdaln_target})
	endif()

endfunction()
