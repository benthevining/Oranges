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

If this variable is not set, this script will use CMake's :external:module:`FetchContent` module to fetch the Oranges sources using Git.

This variable is initialized by the value of the :envvar:`ORANGES_PATH` environment variable.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: ORANGES_PATH

Initializes the :variable:`ORANGES_PATH` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

include (FindPackageMessage)
include (FeatureSummary)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://github.com/benthevining/Oranges"
    DESCRIPTION "CMake modules and scripts")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

if (NOT (DEFINED ORANGES_PATH OR DEFINED CACHE{ORANGES_PATH}))
    if (DEFINED ENV{ORANGES_PATH})
        set (ORANGES_PATH "$ENV{ORANGES_PATH}" CACHE PATH "Path to the Oranges repository")
    endif ()
endif ()

#

include (FindPackageHandleStandardArgs)

# cmake-lint: disable=C0103
macro (__find_Oranges_check_version_from_cmakelists __cmakelists_path __result_var)
    if (NOT EXISTS "${__cmakelists_path}")
        if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
            message (WARNING "CMakeLists.txt does not exist at path ${__cmakelists_path}!")
        endif ()

        set (${__result_var} TRUE)
    else ()
        file (READ "${__cmakelists_path}" __cmakelists_text)

        string (FIND "${__cmakelists_text}" "project (" __project_cmd_pos)

        string (SUBSTRING "${__cmakelists_text}" "${__project_cmd_pos}" 50 __project_cmd_string)

        string (FIND "${__project_cmd_string}" "VERSION" __version_kwd_pos)

        math (EXPR __version_kwd_pos "${__version_kwd_pos} + 8" OUTPUT_FORMAT DECIMAL)

        string (SUBSTRING "${__project_cmd_string}" "${__version_kwd_pos}" 6
                          __project_version_string)

        find_package_check_version ("${__project_version_string}" "${__result_var}"
                                    HANDLE_VERSION_RANGE)
    endif ()
endmacro ()

#

macro (__find_Oranges_post_include_actions)

    list (APPEND CMAKE_MODULE_PATH ${ORANGES_CMAKE_MODULE_PATH})

    set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
endmacro ()

#

# check for local path to dependency

if (ORANGES_PATH)
    if (NOT IS_DIRECTORY "${ORANGES_PATH}")
        if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
            message (WARNING "ORANGES_PATH set to non-existent directory ${ORANGES_PATH}!")
        endif ()
    else ()
        __find_oranges_check_version_from_cmakelists ("${ORANGES_PATH}/CMakeLists.txt"
                                                      local_copy_found)

        if (local_copy_found)
            add_subdirectory ("${ORANGES_PATH}" "${CMAKE_BINARY_DIR}/Oranges")

            __find_oranges_post_include_actions ()

            find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Oranges package found -- local"
                                  "Oranges (local)[${ORANGES_PATH}]")

            return ()
        else ()
            if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
                message (
                    WARNING
                        "Local copy of Oranges has an unsuitable version, falling back to fetching the sources with git..."
                    )
            endif ()
        endif ()
    endif ()
endif ()

#

# fetch from git using FetchContent

set (FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/Cache" CACHE PATH "FetchContent dependency cache")

mark_as_advanced (FETCHCONTENT_BASE_DIR)

include (FetchContent)

FetchContent_Declare (Oranges GIT_REPOSITORY "https://github.com/benthevining/Oranges.git"
                      GIT_TAG "origin/main")

FetchContent_MakeAvailable (Oranges)

__find_oranges_check_version_from_cmakelists ("${oranges_SOURCE_DIR}/CMakeLists.txt"
                                              fetched_copy_works)

if (NOT fetched_copy_works)
    if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
        message (WARNING "Fetched copy of Oranges has an unsuitable version!")
    endif ()

    return ()
endif ()

__find_oranges_post_include_actions ()

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Oranges package found -- Sources downloaded"
                      "Oranges (git)")
