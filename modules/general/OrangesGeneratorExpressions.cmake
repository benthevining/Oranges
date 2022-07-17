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

#

function (oranges_get_debug_config_list outVar)

    get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

    if (NOT debug_configs)
        set (debug_configs Debug)
    endif ()

    set (${outVar} ${debug_configs} PARENT_SCOPE)

endfunction ()

#

function (oranges_make_config_generator_expressions)

    set (oneVal DEBUG RELEASE)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "" ${ARGN})

    oranges_get_debug_config_list (debug_configs)

    set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

    set (config_is_release "$<NOT:${config_is_debug}>")

    if (ORANGES_ARG_DEBUG)
        set (${ORANGES_ARG_DEBUG} "${config_is_debug}" PARENT_SCOPE)
    endif ()

    if (ORANGES_ARG_RELEASE)
        set (${ORANGES_ARG_RELEASE} "${config_is_release}" PARENT_SCOPE)
    endif ()

endfunction ()
