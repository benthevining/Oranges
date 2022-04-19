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

#[=======================================================================[.rst:

Oranges
-------------------------

The Oranges library.

Install components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- oranges_modules
- oranges_toolchains
- oranges_docs

Install component groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- oranges

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

project (
	Oranges
	VERSION 2.17.3
	DESCRIPTION "CMake modules, scripts, and utilities"
	HOMEPAGE_URL "www.github.com/benthevining/Oranges"
	LANGUAGES NONE)

enable_testing ()

if(PROJECT_IS_TOP_LEVEL)
	enable_language (CXX)
endif()

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake")

set (Oranges_DEPS_GRAPH_OUTPUT_TO_SOURCE util)

include (OrangesDefaultProjectSettings)
include (FeatureSummary)

unset (Oranges_DEPS_GRAPH_OUTPUT_TO_SOURCE)

#

set (ORANGES_INSTALL_DEST "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
	 CACHE STRING "Directory below INSTALL_PREFIX where Oranges will be installed to")

#

add_subdirectory (docs)
add_subdirectory (help)

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/update_readme.cmake")

#

# include any modules that create targets (for installing)
include (OrangesAllIntegrations)
include (OrangesCoverageFlags)
include (OrangesDefaultTarget)
include (OrangesDefaultWarnings)
include (OrangesUnityBuild)
include (OrangesGenerateExportHeader)

#

mark_as_advanced (FORCE ORANGES_INSTALL_DEST)

install (
	EXPORT OrangesTargets
	NAMESPACE Oranges::
	DESTINATION "${ORANGES_INSTALL_DEST}"
	EXPORT_LINK_INTERFACE_LIBRARIES
	COMPONENT oranges_base)

write_basic_package_version_file ("OrangesConfigVersion.cmake" VERSION "${PROJECT_VERSION}"
								  COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

configure_package_config_file (
	"${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesConfig.cmake" OrangesConfig.cmake
	INSTALL_DESTINATION "${ORANGES_INSTALL_DEST}" PATH_VARS ORANGES_ROOT_DIR)

install (
	FILES "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfigVersion.cmake"
		  "${CMAKE_CURRENT_BINARY_DIR}/OrangesConfig.cmake"
		  "${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake"
	DESTINATION "${ORANGES_INSTALL_DEST}"
	COMPONENT oranges_base)

install (DIRECTORY modules DESTINATION "${ORANGES_INSTALL_DEST}" COMPONENT oranges_modules
		 PATTERN .DS_Store EXCLUDE)

install (DIRECTORY toolchains DESTINATION "${ORANGES_INSTALL_DEST}" COMPONENT oranges_toolchains
		 PATTERN .DS_Store EXCLUDE)

cpack_add_component (oranges_base HIDDEN)

cpack_add_component (
	oranges_modules
	DISPLAY_NAME "Oranges CMake modules"
	DESCRIPTION "Install the Oranges CMake modules"
	GROUP oranges
	DEPENDS oranges_base
	INSTALL_TYPES Developer)

cpack_add_component (
	oranges_toolchains
	DISPLAY_NAME "Oranges CMake toolchains"
	DESCRIPTION "Install the Oranges CMake toolchain files"
	GROUP oranges
	DEPENDS oranges_base
	INSTALL_TYPES Developer)

cpack_add_component_group (
	oranges
	DISPLAY_NAME Oranges
	DESCRIPTION "Install all components of the Oranges library"
	BOLD_TITLE
	PARENT_GROUP Citrus)

cpack_add_install_type (Developer DISPLAY_NAME "Developer installation")

feature_summary (FILENAME "${CMAKE_BINARY_DIR}/package_features.txt" INCLUDE_QUIET_PACKAGES
																	 DEFAULT_DESCRIPTION WHAT ALL)

if(PROJECT_IS_TOP_LEVEL)
	feature_summary (INCLUDE_QUIET_PACKAGES DEFAULT_DESCRIPTION QUIET_ON_EMPTY WHAT ALL)
endif()

export (PACKAGE Oranges)

unset (ORANGES_ROOT_DIR)
