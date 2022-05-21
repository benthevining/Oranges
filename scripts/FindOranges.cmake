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

FindOranges
-------------------------

A find module for Oranges itself.

This file can be copied verbatim into any projects that depend on Oranges, and committed to their source control -- this is what I do for my projects.

You can then use the environment or command line variable :variable:`ORANGES_PATH` to turn this find module into an :external:command:`add_subdirectory() <add_subdirectory>` of a local copy of Oranges;
if neither variable is set, this module will use :external:module:`FetchContent` to download the Oranges sources from GitHub.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: ORANGES_PATH

This variable may be set to a local copy of the Oranges repository, in which case calling ``find_package (Oranges)`` will result in this script executing ``add_subdirectory (${ORANGES_PATH})``.

If this variable is not set, this script will use CMake's :external:module:`FetchContent` module to fetch the Oranges sources from GitHub.

This variable is initialized by the value of the :envvar:`ORANGES_PATH` environment variable.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: ORANGES_PATH

Initializes the :variable:`ORANGES_PATH` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

#

include (FindPackageMessage)
include (FeatureSummary)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://github.com/benthevining/Oranges"
    DESCRIPTION "Library of CMake modules")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

if (NOT (DEFINED ORANGES_PATH OR DEFINED CACHE{ORANGES_PATH}))
    if (DEFINED ENV{ORANGES_PATH})
        set (ORANGES_PATH "$ENV{ORANGES_PATH}" CACHE PATH "Path to the Oranges repository")
    endif ()
endif ()

# cmake-lint: disable=C0103
function (_find_oranges_try_local_dir)
    if (NOT IS_DIRECTORY "${ORANGES_PATH}")
        message (WARNING "ORANGES_PATH set to non-existent directory ${ORANGES_PATH}!")
        return ()
    endif ()

    set (oranges_cmakelists "${ORANGES_PATH}/CMakeLists.txt")

    if (NOT EXISTS "${oranges_cmakelists}")
        message (WARNING "CMakeLists.txt does not exist in supplied ORANGES_PATH: ${ORANGES_PATH}!")
        return ()
    endif ()

    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION)
        file (READ "${oranges_cmakelists}" cmakelists_text)

        string (FIND "${cmakelists_text}" "project (" project_pos)

        string (SUBSTRING "${cmakelists_text}" "${project_pos}" 50 project_string)

        string (FIND "${project_string}" "VERSION" version_pos)

        math (EXPR version_pos "${version_pos} + 8" OUTPUT_FORMAT DECIMAL)

        string (SUBSTRING "${project_string}" "${version_pos}" 6 version_string)

        if (${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION_EXACT)
            if (NOT "${version_string}" VERSION_EQUAL "${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION}")
                message (
                    WARNING
                        "Local version of Oranges doesn't have EXACT version requested (${version_string}, requested ${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION})"
                    )
                return ()
            endif ()
        else ()
            if ("${version_string}" VERSION_LESS "${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION}")
                message (
                    WARNING
                        "Local version of Oranges has too old version (${version_string}, requested ${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION})"
                    )
                return ()
            endif ()
        endif ()
    endif ()

    add_subdirectory ("${ORANGES_PATH}" "${CMAKE_BINARY_DIR}/Oranges")

    find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Oranges package found -- local"
                          "Oranges (local)[${ORANGES_PATH}]")

    set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE PARENT_SCOPE)
endfunction ()

if (ORANGES_PATH)
    _find_oranges_try_local_dir ()
endif ()

if (${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    list (APPEND CMAKE_MODULE_PATH "${ORANGES_CMAKE_MODULE_PATH}")
    return ()
endif ()

#

set (FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/Cache" CACHE PATH "FetchContent dependency cache")

mark_as_advanced (FORCE FETCHCONTENT_BASE_DIR)

include (FetchContent)

FetchContent_Declare (Oranges GIT_REPOSITORY https://github.com/benthevining/Oranges.git
                      GIT_TAG origin/main)

FetchContent_MakeAvailable (Oranges)

list (APPEND CMAKE_MODULE_PATH "${ORANGES_CMAKE_MODULE_PATH}")

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Oranges package found -- Sources downloaded"
                      "Oranges (GitHub)")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
