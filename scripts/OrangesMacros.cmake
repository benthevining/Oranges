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

if ((NOT ORANGES_ROOT_DIR) OR NOT IS_DIRECTORY "${ORANGES_ROOT_DIR}")
    message (
        FATAL_ERROR
            "Oranges root directory ${ORANGES_ROOT_DIR} not specified or does not exist!"
        )
endif ()

#

function (_oranges_add_cmake_module_dir directory parent)
    set (full_path "${parent}/${directory}")

    if (NOT IS_DIRECTORY "${full_path}")
        return ()
    endif ()

    # cmake-lint: disable=E1126
    file (REAL_PATH "${full_path}" _abs_path EXPAND_TILDE)
    list (APPEND orangesModulePaths "${_abs_path}")

    file (GLOB dirChildren RELATIVE "${_abs_path}" "${_abs_path}/*")

    list (REMOVE_ITEM dirChildren scripts)

    foreach (child IN LISTS dirChildren)
        _oranges_add_cmake_module_dir ("${child}" "${_abs_path}")
    endforeach ()

    set (orangesModulePaths "${orangesModulePaths}" PARENT_SCOPE)
endfunction ()

#

file (GLOB children RELATIVE "${ORANGES_ROOT_DIR}"
      "${ORANGES_ROOT_DIR}/modules/*")

foreach (child IN LISTS children)
    _oranges_add_cmake_module_dir ("${child}" "${ORANGES_ROOT_DIR}")
endforeach ()

#

list (REMOVE_DUPLICATES orangesModulePaths)
list (REMOVE_ITEM orangesModulePaths "")

set (ORANGES_CMAKE_MODULE_PATH "${orangesModulePaths}" CACHE INTERNAL "")

list (APPEND CMAKE_MODULE_PATH "${orangesModulePaths}")

list (REMOVE_DUPLICATES CMAKE_MODULE_PATH)

unset (orangesModulePaths)
