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

include (OrangesListUtils)

set (RELEASE_CONFIGURATIONS Release RelWithDebInfo MinSizeRel CACHE STRING "Release configurations")

function(_oranges_release_config_list_transform input output)
	set (${output} "$<CONFIG:input>" PARENT_SCOPE)
endfunction()

oranges_list_transform (LIST RELEASE_CONFIGURATIONS CALLBACK _oranges_release_config_list_transform
						OUTPUT rel_configs)

list (JOIN rel_configs "," rel_configs)

set (GEN_ANY_REL_CONFIG "$<OR:${rel_configs}>" CACHE INTERNAL "")

unset (rel_configs)
