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

macro (lemons_require_function_arguments prefix)
    foreach (requiredArgument ${ARGN})
        if (NOT ${prefix}_${requiredArgument})
            message (
                FATAL_ERROR
                    "Required argument ${requiredArgument} not specified in call to ${CMAKE_CURRENT_FUNCTION}!"
                )
        endif ()
    endforeach ()
endmacro ()

#

macro (lemons_check_for_unparsed_args prefix)
    if (${prefix}_UNPARSED_ARGUMENTS)
        message (
            FATAL_ERROR
                "Unparsed arguments ${${prefix}_UNPARSED_ARGUMENTS} found in call to ${CMAKE_CURRENT_FUNCTION}!"
            )
    endif ()
endmacro ()

#

macro (oranges_assert_target_argument_is_target prefix)
    lemons_require_function_arguments ("${prefix}" TARGET)

    if (NOT TARGET "${${prefix}_TARGET}")
        message (
            FATAL_ERROR
                "${CMAKE_CURRENT_FUNCTION} called with non-existent target ${${prefix}_TARGET}!")
    endif ()
endmacro ()

#

function (oranges_forward_function_argument)

    set (oneValueArgs PREFIX ARG KIND)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG PREFIX ARG KIND)

    set (variable_name "${PREFIX}_${ORANGES_ARG_ARG}")

    if (${variable_name})
        if ("${ORANGES_ARG_KIND}" STREQUAL "option")
            set (new_flag "${ORANGES_ARG_ARG}")
        elseif ("${ORANGES_ARG_KIND}" STREQUAL "oneVal")
            set (new_flag "${ORANGES_ARG_ARG}" "${variable_name}")
        elseif ("${ORANGES_ARG_KIND}" STREQUAL "multiVal")
            set (new_flag "${ORANGES_ARG_ARG}" ${variable_name})
        else ()
            message (
                FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - invalid KIND argument ${ORANGES_ARG_KIND}!"
                )
        endif ()
    endif ()

    if (new_flag)
        list (APPEND ORANGES_FORWARDED_ARGUMENTS ${new_flag})

        set (ORANGES_FORWARDED_ARGUMENTS ${ORANGES_FORWARDED_ARGUMENTS} PARENT_SCOPE)
    endif ()

endfunction ()

#

function (oranges_forward_function_arguments)

    set (oneValueArgs PREFIX KIND)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "ARGS" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG PREFIX KIND ARGS)

    foreach (argument ${ORANGES_ARG_ARGS})
        oranges_forward_function_argument (PREFIX "${ORANGES_ARG_PREFIX}" ARG "${argument}" KIND
                                           "${ORANGES_ARG_KIND}")
    endforeach ()

    set (ORANGES_FORWARDED_ARGUMENTS ${ORANGES_FORWARDED_ARGUMENTS} PARENT_SCOPE)

endfunction ()
