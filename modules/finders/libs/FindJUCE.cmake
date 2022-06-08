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

FindJUCE
-------------------------

A find module for the JUCE library. This module fetches the JUCE sources from GitHub using :module:`OrangesFetchRepository`.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: ORANGES_JUCE_BRANCH

The branch of JUCE's GitHub repository to use when fetching the sources from GitHub; either ``develop`` or ``master``. Defaults to ``master``.

.. cmake:variable:: JUCE_CORE_DIR

The path to the ``juce_core`` JUCE module.
When searching for this path, the environment variable :envvar:`JUCE_CORE_DIR` is added to the search path.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: JUCE_CORE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`JUCE_CORE_DIR` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://juce.com/"
                        DESCRIPTION "Cross platform framework for plugin and app development")

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

find_path (JUCE_CORE_DIR juce_core.h PATHS ENV JUCE_CORE_DIR
           DOC "Directory of the juce_core module")

set (JUCE_ENABLE_MODULE_SOURCE_GROUPS ON)
set (JUCE_BUILD_EXAMPLES OFF)
set (JUCE_BUILD_EXTRAS OFF)

if (JUCE_CORE_DIR)
    set (juce_find_location Local)

    add_subdirectory ("${JUCE_CORE_DIR}/../.." "${CMAKE_CURRENT_BINARY_DIR}/JUCE")
else ()
    include (OrangesFetchRepository)

    set (ORANGES_JUCE_BRANCH "master" CACHE STRING
                                            "The branch of the JUCE GitHub repository to use")
    set_property (CACHE ORANGES_JUCE_BRANCH PROPERTY STRINGS "develop;master")
    mark_as_advanced (ORANGES_JUCE_BRANCH)

    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
        set (quiet_flag QUIET)
    endif ()

    oranges_fetch_repository (NAME JUCE GITHUB_REPOSITORY juce-framework/JUCE
                              GIT_TAG "origin/${ORANGES_JUCE_BRANCH}" NEVER_LOCAL ${quiet_flag})

    unset (quiet_flag)

    set (juce_find_location Downloaded)

    set (JUCE_CORE_DIR "${JUCE_SOURCE_DIR}/modules/juce_core"
         CACHE PATH "Directory of the juce_core module" FORCE)
endif ()

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "JUCE - found (${juce_find_location})"
                      "JUCE [${juce_find_location}] [${JUCE_CORE_DIR}]")

unset (juce_find_location)
