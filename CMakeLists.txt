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

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: ORANGES_MAINTAINER_BUILD

When ``ON``, OrangesDefaultTarget will link to OrangesDefaultWarnings and OrangesStaticAnalysis. ``OFF`` by default.

.. cmake:variable:: ORANGES_IOS_DEV_TEAM_ID

10-character Apple developer ID used to set up code signing on iOS. Initialized by the value of :envvar:`APPLE_DEV_ID`, if set.

.. cmake:variable:: ORANGES_MAC_UNIVERSAL_BINARY

If true, and the Xcode generator is being used, and running on an M1 Mac, configures generation of universal binaries for both arm64 and x86_64 architectures.

.. cmake:variable:: ORANGES_BUILD_DOCS

When on, builds the HTML and man page documentation. Defaults to on if Oranges is the top-level project.

Building the docs requires Python 3.9 and Sphinx.

.. cmake:variable:: ORANGES_SPHINX_FLAGS

When building the documentation, this can contain a space-separated list of flags that will be passed to the Sphinx executable while building each documentation format.
Empty by default.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: APPLE_DEV_ID

The 10-character Apple developer ID used to configure code signing on iOS. If set, this initializes the value of the :variable:`ORANGES_IOS_DEV_TEAM_ID`.

Install components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- oranges_modules
- oranges_doc_html
- oranges_doc_singlehtml
- oranges_doc_man
- oranges_doc_info
- oranges_doc_pdf

Install component groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- oranges_docs
- oranges

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

project (
    Oranges
    VERSION 3.0.0
    DESCRIPTION "CMake modules, scripts, and utilities"
    HOMEPAGE_URL "www.github.com/benthevining/Oranges"
    LANGUAGES NONE)

option (CMAKE_FIND_PACKAGE_PREFER_CONFIG
        "Prefer config files to find modules in find_package search" ON)

option (ORANGES_BUILD_DOCS "Build the documentation" "${PROJECT_IS_TOP_LEVEL}")

mark_as_advanced (CMAKE_FIND_PACKAGE_PREFER_CONFIG)

enable_testing ()

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

include (cmake/OrangesMacros.cmake)

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

    include (OrangesWipeCacheTarget)
    include (OrangesDefaultCPackSettings)
else ()
    # check if no languages are enabled (need at least one for GNUInstallDirs)
    get_property (enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES)

    if (NOT enabled_languages OR "${enabled_languages}" STREQUAL NONE)
        enable_language (CXX)
    endif ()
endif ()

#

include (GNUInstallDirs)

set (ORANGES_INSTALL_DEST "${CMAKE_INSTALL_LIBDIR}/cmake/Oranges"
     CACHE STRING "Directory below INSTALL_PREFIX where Oranges will be installed to")

mark_as_advanced (FORCE ORANGES_INSTALL_DEST)

#

add_subdirectory (targets)

add_subdirectory (modules/helper_targets)

#

include (CPackComponent)

if (ORANGES_BUILD_DOCS)
    find_package (Python3 3.9 COMPONENTS Interpreter)

    include (OrangesGraphviz)

    oranges_add_graphviz_target (
        TARGET OrangesDependencyGraph SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}"
        COPY_GRAPH_TO "${CMAKE_CURRENT_LIST_DIR}/util/deps_graph.png")

    include (cmake/update_readme.cmake)

    add_subdirectory (docs)

    set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
                  PROPERTY ADDITIONAL_CLEAN_FILES "${CMAKE_CURRENT_LIST_DIR}/doc")
endif ()

#

install (
    EXPORT OrangesTargets
    NAMESPACE Oranges::
    DESTINATION "${ORANGES_INSTALL_DEST}"
    EXPORT_LINK_INTERFACE_LIBRARIES
    COMPONENT oranges_base)

export (EXPORT OrangesTargets FILE "${CMAKE_CURRENT_BINARY_DIR}/OrangesTargets.cmake"
        NAMESPACE Oranges::)

set (Oranges_DIR "${CMAKE_CURRENT_BINARY_DIR}" CACHE INTERNAL "")

export (PACKAGE Oranges)

file (COPY_FILE cmake/OrangesMacros.cmake "${CMAKE_CURRENT_BINARY_DIR}/OrangesMacros.cmake")

file (TOUCH "${CMAKE_CURRENT_BINARY_DIR}/OrangesTargets.cmake")

include (CMakePackageConfigHelpers)

write_basic_package_version_file (Oranges-config-version.cmake VERSION "${PROJECT_VERSION}"
                                  COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

configure_package_config_file (
    cmake/Oranges-config.cmake Oranges-config.cmake INSTALL_DESTINATION "${ORANGES_INSTALL_DEST}"
    PATH_VARS ORANGES_ROOT_DIR)

install (
    FILES "${CMAKE_CURRENT_BINARY_DIR}/Oranges-config-version.cmake"
          "${CMAKE_CURRENT_BINARY_DIR}/Oranges-config.cmake"
          "${CMAKE_CURRENT_LIST_DIR}/cmake/OrangesMacros.cmake"
    DESTINATION "${ORANGES_INSTALL_DEST}"
    COMPONENT oranges_base)

install (DIRECTORY modules DESTINATION "${ORANGES_INSTALL_DEST}" COMPONENT oranges_modules
         PATTERN .DS_Store EXCLUDE)

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
         COMPONENT oranges_base)

if (PROJECT_IS_TOP_LEVEL)
    feature_summary (INCLUDE_QUIET_PACKAGES DEFAULT_DESCRIPTION QUIET_ON_EMPTY WHAT ALL)

    include (OrangesUninstallTarget)
endif ()
