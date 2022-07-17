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

A find module for the JUCE library.
This module attempts to locate a local copy of JUCE, and if this fails, fetches the JUCE sources from GitHub using CMake's ``FetchContent`` module.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: JUCE_PATH

This variable can be set to the path to the root of the JUCE repository.
If this variable is defined, this path will be added using ``add_subdirectory()``.

.. cmake:variable:: JUCE_BRANCH

The branch of JUCE's GitHub repository to use when fetching the sources from GitHub; either ``develop`` or ``master``. Defaults to ``master``.

.. cmake:variable:: JUCE_CORE_DIR

The path to the ``juce_core`` JUCE module.
If ``JUCE_PATH`` is not defined, this module will attempt to locate a local copy of JUCE by finding the ``juce_core.h`` file.
When searching for this path, the environment variable :envvar:`JUCE_CORE_DIR` is added to the search path.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: JUCE_PATH

This environment variable initializes the value of the :variable:`JUCE_PATH` variable.

.. cmake:envvar:: JUCE_CORE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`JUCE_CORE_DIR` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://juce.com/"
                        DESCRIPTION "Cross platform framework for plugin and app development")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

find_path (JUCE_CORE_DIR juce_core.h PATHS "${JUCE_PATH}/modules/juce_core" ENV JUCE_CORE_DIR
           DOC "Directory of the juce_core module")

set (JUCE_PATH "${JUCE_CORE_DIR}/../.." CACHE PATH "Path to the JUCE repository")

set (JUCE_BRANCH "master" CACHE STRING "The branch of the JUCE GitHub repository to use")

set_property (CACHE JUCE_BRANCH PROPERTY STRINGS develop master)

mark_as_advanced (JUCE_CORE_DIR JUCE_PATH JUCE_BRANCH)

#

set (JUCE_ENABLE_MODULE_SOURCE_GROUPS ON)
set (JUCE_BUILD_EXAMPLES OFF)
set (JUCE_BUILD_EXTRAS OFF)

if (IS_DIRECTORY "${JUCE_PATH}")
    set (juce_find_location Local)

    add_subdirectory ("${JUCE_PATH}" "${CMAKE_CURRENT_BINARY_DIR}/JUCE")
else ()
    include (FetchContent)

    FetchContent_Declare (JUCE GIT_REPOSITORY "https://github.com/juce-framework/JUCE.git"
                          GIT_TAG "origin/${JUCE_BRANCH}")

    FetchContent_MakeAvailable (JUCE)

    set (JUCE_PATH "${juce_SOURCE_DIR}" CACHE PATH "Path to the JUCE repository" FORCE)
    set (JUCE_CORE_DIR "${JUCE_PATH}/modules/juce_core"
         CACHE PATH "Directory of the juce_core module" FORCE)

    set (juce_find_location Downloaded)
endif ()

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message (
    "${CMAKE_FIND_PACKAGE_NAME}" "JUCE - found (${juce_find_location})"
    "JUCE [${juce_find_location}] [${JUCE_CORE_DIR}] [${JUCE_PATH}] [${JUCE_BRANCH}]")

unset (juce_find_location)
