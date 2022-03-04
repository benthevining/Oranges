include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

project (
	Oranges
	VERSION 0.1.0
	DESCRIPTION "CMake modules, scripts, and utilities"
	HOMEPAGE_URL "www.github.com/benthevining/Oranges"
	LANGUAGES NONE)

if(PROJECT_IS_TOP_LEVEL)
	enable_language (CXX)
	enable_language (C)
endif()

set (CPM_Oranges_SOURCE "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

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

#

set (CMAKE_DEBUG_POSTFIX -d)

add_library (Oranges INTERFACE)

include (GNUInstallDirs)

install (
	TARGETS Oranges
	EXPORT OrangesTargets
	OPTIONAL
	LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
	ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
	RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
	INCLUDES
	DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

include (OrangesDefaultTarget)

target_link_libraries (Oranges INTERFACE OrangesDefaultTarget)

add_library (Oranges::Oranges ALIAS Oranges)

install (EXPORT OrangesTargets FILE OrangesTargets.cmake NAMESPACE Oranges::
		 DESTINATION lib/cmake/Oranges)
export (EXPORT OrangesTargets FILE "${CMAKE_CURRENT_BINARY_DIR}/cmake/OrangesTargets.cmake"
		NAMESPACE Oranges::)

#

include (CMakePackageConfigHelpers)

write_basic_package_version_file ("OrangesConfigVersion.cmake" VERSION "${PROJECT_VERSION}"
								  COMPATIBILITY SameMajorVersion)

configure_package_config_file (
	"${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesConfig.cmake" "OrangesConfig.cmake"
	INSTALL_DESTINATION lib/cmake/Oranges PATH_VARS "" INSTALL_PREFIX "")

if(PROJECT_IS_TOP_LEVEL)
	include (CPack)
endif()
