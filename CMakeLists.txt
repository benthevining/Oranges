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

The Oranges CMake library.

Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ORANGES_BUILD_DOCS

Install components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- oranges_modules
- oranges_doc_html
- oranges_doc_singlehtml

Install component groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- oranges_docs
- oranges

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

project (
    Oranges
    VERSION 2.23.3
    DESCRIPTION "CMake modules, scripts, and utilities"
    HOMEPAGE_URL "www.github.com/benthevining/Oranges"
    LANGUAGES NONE)

option (CMAKE_FIND_PACKAGE_PREFER_CONFIG
        "Prefer config files to find modules in find_package search" ON)

option (ORANGES_BUILD_DOCS "Build the documentation" "${PROJECT_IS_TOP_LEVEL}")

mark_as_advanced (CMAKE_FIND_PACKAGE_PREFER_CONFIG)

enable_testing ()

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/OrangesMacros.cmake")

#

if (PROJECT_IS_TOP_LEVEL)
    enable_language (CXX)

    # cmake-format: off
	set_property (
		GLOBAL PROPERTY
			USE_FOLDERS YES
			PREDEFINED_TARGETS_FOLDER Targets
			REPORT_UNDEFINED_PROPERTIES "${CMAKE_BINARY_DIR}/undefined_properties.log")
	# cmake-format: on

    set (CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
    set (CMAKE_INSTALL_MESSAGE LAZY)
    set (CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION ON)

    include (OrangesDeprecateDirectoryScopedCommands)
    include (OrangesWipeCacheTarget)
    include (OrangesDefaultCPackSettings)

    set (Oranges_DEPS_GRAPH_OUTPUT_TO_SOURCE util)

    include (OrangesGraphVizConfig)

    unset (Oranges_DEPS_GRAPH_OUTPUT_TO_SOURCE)
endif ()

#

include (GNUInstallDirs)

set (ORANGES_INSTALL_DEST "${CMAKE_INSTALL_LIBDIR}/cmake/Oranges"
     CACHE STRING "Directory below INSTALL_PREFIX where Oranges will be installed to")

mark_as_advanced (FORCE ORANGES_INSTALL_DEST)

# include any modules that create targets (for installing)
include (CXXConcepts)
include (OrangesAllIntegrations)
include (OrangesCoverageFlags)
include (OrangesDefaultTarget)
include (OrangesDefaultWarnings)
include (OrangesGenerateExportHeader)
include (OrangesUnityBuild)

set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                    "${CMAKE_CURRENT_LIST_DIR}/doc")

#

if (ORANGES_BUILD_DOCS)
    include ("${CMAKE_CURRENT_LIST_DIR}/scripts/update_readme.cmake")

    add_subdirectory (docs)
endif ()

#

install (
    EXPORT OrangesTargets
    NAMESPACE Oranges::
    DESTINATION "${ORANGES_INSTALL_DEST}"
    EXPORT_LINK_INTERFACE_LIBRARIES
    COMPONENT oranges_base)

include (CMakePackageConfigHelpers)

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

include (CPackComponent)

cpack_add_component (oranges_base HIDDEN GROUP oranges)

cpack_add_component (
    oranges_modules
    DISPLAY_NAME "Oranges CMake modules"
    DESCRIPTION "Install the Oranges CMake modules"
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

#

include (FeatureSummary)

feature_summary (
    FILENAME "${PROJECT_BINARY_DIR}/package_features.txt"
    INCLUDE_QUIET_PACKAGES
    WHAT ALL
    DESCRIPTION
        "This version of Oranges was configured with the following features and third party libraries:"
    )

install (FILES "${PROJECT_BINARY_DIR}/package_features.txt" DESTINATION "${ORANGES_INSTALL_DEST}"
         CONFIGURATIONS Debug COMPONENT oranges_base)

if (PROJECT_IS_TOP_LEVEL)
    feature_summary (INCLUDE_QUIET_PACKAGES DEFAULT_DESCRIPTION QUIET_ON_EMPTY WHAT ALL)

    include (OrangesUninstallTarget)
endif ()

export (PACKAGE Oranges)

unset (ORANGES_ROOT_DIR)

set (Oranges_FOUND TRUE CACHE INTERNAL "")
