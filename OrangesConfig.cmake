include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

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
