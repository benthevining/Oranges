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

include (OrangesCmakeDevTools)

add_custom_target (LEMONS_ALL_APPS COMMENT "Building all apps...")
add_custom_target (LEMONS_ALL_PLUGINS COMMENT "Building all plugins...")

oranges_export_alias_target (LEMONS_ALL_APPS Lemons)
oranges_export_alias_target (LEMONS_ALL_PLUGINS Lemons)

oranges_install_targets (TARGETS LEMONS_ALL_APPS LEMONS_ALL_PLUGINS EXPORT
						 OrangesTargets OPTIONAL)

#

function (_lemons_add_to_all_apps_target target)
	add_dependencies (LEMONS_ALL_APPS "${target}")
endfunction ()

#

function (_lemons_add_to_all_plugins_target target)

	add_dependencies (LEMONS_ALL_PLUGINS "${target}_All")

	set (stdaln_target "${target}_Standalone")

	if (TARGET "${stdaln_target}")
		_lemons_add_to_all_apps_target ("${stdaln_target}")
	endif ()

endfunction ()
