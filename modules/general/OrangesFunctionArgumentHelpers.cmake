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

macro (oranges_require_function_arguments __prefix)
    foreach (__requiredArgument ${ARGN})
        if (NOT ${__prefix}_${__requiredArgument})
            message (
                FATAL_ERROR
                    "Required argument ${__requiredArgument} not specified in call to ${CMAKE_CURRENT_FUNCTION}!"
                )
        endif ()
    endforeach ()
endmacro ()

#

macro (oranges_check_for_unparsed_args __prefix)
    if (${__prefix}_UNPARSED_ARGUMENTS)
        message (
            FATAL_ERROR
                "Unparsed arguments ${${__prefix}_UNPARSED_ARGUMENTS} found in call to ${CMAKE_CURRENT_FUNCTION}!"
            )
    endif ()
endmacro ()

#

macro (oranges_assert_target_argument_is_target __prefix)
    oranges_require_function_arguments ("${__prefix}" TARGET)

    if (NOT TARGET "${${__prefix}_TARGET}")
        message (
            FATAL_ERROR
                "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${${__prefix}_TARGET}!")
    endif ()
endmacro ()
