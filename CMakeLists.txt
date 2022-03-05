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
set (Oranges_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")
set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake")

install (FILES ${ORANGES_CMAKE_MODULE_SOURCES} DESTINATION /modules)

install (FILES "${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake" DESTINATION .)

#

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
	DESTINATION include)

include (OrangesDefaultTarget)

target_link_libraries (Oranges INTERFACE OrangesDefaultTarget)

add_library (Oranges::Oranges ALIAS Oranges)

install (EXPORT OrangesTargets FILE OrangesTargets.cmake NAMESPACE Oranges::
		 DESTINATION lib/cmake/Oranges)

if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/OrangesTargets.cmake")
	install (FILES "${CMAKE_CURRENT_BINARY_DIR}/OrangesTargets.cmake" DESTINATION .)
endif()

#

include (CMakePackageConfigHelpers)

write_basic_package_version_file ("OrangesConfigVersion.cmake" VERSION "${PROJECT_VERSION}"
								  COMPATIBILITY SameMajorVersion)

configure_package_config_file (
	"${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesConfig.cmake" OrangesConfig.cmake
	INSTALL_DESTINATION lib/cmake/Oranges PATH_VARS ORANGES_ROOT_DIR INSTALL_PREFIX "")

install (FILES "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfigVersion.cmake"
			   "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfig.cmake" DESTINATION .)

include (LemonsDefaultCPackSettings)

export (PACKAGE Oranges)
