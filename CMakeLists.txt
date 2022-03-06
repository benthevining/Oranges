include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

project (
	Oranges
	VERSION 0.1.0
	DESCRIPTION "CMake modules, scripts, and utilities"
	HOMEPAGE_URL "www.github.com/benthevining/Oranges"
	LANGUAGES NONE)

set (ORANGES_INSTALL_DEST lib/cmake/Oranges
	 CACHE STRING "Directory below INSTALL_PREFIX where Oranges will be installed to")

mark_as_advanced (FORCE ORANGES_INSTALL_DEST)

if(PROJECT_IS_TOP_LEVEL)
	enable_language (CXX)
	enable_language (C)
endif()

set (CPM_Oranges_SOURCE "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")
set (Oranges_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake")

#

add_library (Oranges INTERFACE)

include (LemonsCmakeDevTools)

oranges_install_targets (
	TARGETS
	Oranges
	EXPORT
	OrangesTargets
	REL_PATH
	"${ORANGES_INSTALL_DEST}"
	OPTIONAL)

include (OrangesDefaultTarget)

target_link_libraries (Oranges INTERFACE OrangesDefaultTarget)

oranges_export_alias_target (Oranges Oranges)

#

add_subdirectory (docs)

#

include (CMakePackageConfigHelpers)

write_basic_package_version_file ("OrangesConfigVersion.cmake" VERSION "${PROJECT_VERSION}"
								  COMPATIBILITY SameMajorVersion)

configure_package_config_file (
	"${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesConfig.cmake" OrangesConfig.cmake
	INSTALL_DESTINATION lib/cmake/Oranges PATH_VARS ORANGES_ROOT_DIR INSTALL_PREFIX "")

install (EXPORT OrangesTargets NAMESPACE Oranges:: DESTINATION "${ORANGES_INSTALL_DEST}"
		 EXPORT_LINK_INTERFACE_LIBRARIES)

install (DIRECTORY modules toolchains DESTINATION "${ORANGES_INSTALL_DEST}" PATTERN .DS_Store
																					EXCLUDE)

install (
	FILES "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfigVersion.cmake"
		  "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfig.cmake"
		  "${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake"
	DESTINATION "${ORANGES_INSTALL_DEST}")

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesUninstallTarget)
	include (LemonsDefaultCPackSettings)

	set (CPACK_PROJECT_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/CPackConfig.cmake")
endif()

export (PACKAGE Oranges)
