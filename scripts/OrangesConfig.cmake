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

include (CMakeFindDependencyMacro)

@PACKAGE_INIT@

# find_dependency ()

include ("${CMAKE_CURRENT_LIST_DIR}/OrangesTargets.cmake")

#

check_required_components ("@PROJECT_NAME@")

#

function(_lemons_add_cmake_module_dir directory parent)
	set (full_path "${parent}/${directory}")

	if(IS_DIRECTORY "${full_path}")
		if("${full_path}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
			return ()
		endif()

		file (REAL_PATH "${full_path}" _abs_path EXPAND_TILDE)
		list (APPEND lemonsModulePaths "${_abs_path}")

		file (GLOB dirChildren RELATIVE ${_abs_path} ${_abs_path}/*)

		list (REMOVE_ITEM dirChildren scripts)

		foreach(child ${dirChildren})
			_lemons_add_cmake_module_dir ("${child}" "${_abs_path}")
		endforeach()
	endif()

	set (lemonsModulePaths "${lemonsModulePaths}" PARENT_SCOPE)
endfunction()

file (GLOB children RELATIVE ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/modules/*)

foreach(child ${children})
	_lemons_add_cmake_module_dir ("${child}" "${CMAKE_CURRENT_LIST_DIR}")
endforeach()

#

list (APPEND CMAKE_MODULE_PATH "${lemonsModulePaths}")
list (APPEND LEMONS_CMAKE_MODULE_PATH "${lemonsModulePaths}")

list (REMOVE_DUPLICATES LEMONS_CMAKE_MODULE_PATH)
list (REMOVE_DUPLICATES CMAKE_MODULE_PATH)

set (LEMONS_CMAKE_MODULE_PATH "${LEMONS_CMAKE_MODULE_PATH}" CACHE INTERNAL "")
set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" CACHE INTERNAL "")
