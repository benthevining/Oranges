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

project (
	Oranges
	VERSION 1.26.1
	DESCRIPTION "CMake modules, scripts, and utilities"
	HOMEPAGE_URL "www.github.com/benthevining/Oranges"
	LANGUAGES NONE)

enable_testing ()

if(PROJECT_IS_TOP_LEVEL)
	enable_language (CXX)
endif()

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake")

set (Oranges_SKIP_PKGCONFIG ON)

include (OrangesDefaultProjectSettings)

#

add_library (Oranges INTERFACE)

oranges_install_targets (
	TARGETS
	Oranges
	EXPORT
	OrangesTargets
	REL_PATH
	Oranges
	OPTIONAL)

target_link_libraries (Oranges INTERFACE Oranges::OrangesDefaultTarget)

oranges_export_alias_target (Oranges Oranges)

#

oranges_create_doxygen_target (
	TARGET
	OrangesDoxygen
	INPUT_PATHS
	modules
	toolchains
	FILE_PATTERNS
	*.cmake)

#

write_basic_package_version_file ("OrangesConfigVersion.cmake" VERSION "${PROJECT_VERSION}"
								  COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

configure_package_config_file (
	"${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesConfig.cmake" OrangesConfig.cmake
	INSTALL_DESTINATION "${Oranges_INSTALL_DEST}" PATH_VARS ORANGES_ROOT_DIR)

install (EXPORT OrangesTargets NAMESPACE Oranges:: DESTINATION "${Oranges_INSTALL_DEST}"
		 EXPORT_LINK_INTERFACE_LIBRARIES)

export (EXPORT OrangesTargets NAMESPACE Oranges:: FILE OrangesTargets.cmake)

install (DIRECTORY modules toolchains DESTINATION "${Oranges_INSTALL_DEST}" PATTERN .DS_Store
																					EXCLUDE)

install (
	FILES "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfigVersion.cmake"
		  "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfig.cmake"
		  "${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake"
	DESTINATION "${Oranges_INSTALL_DEST}")

export (PACKAGE Oranges)
