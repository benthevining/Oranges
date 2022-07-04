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

FindMIPP
-------------------------

A find module for the MIPP library.
This module fetches the sources from GitHub using CMake's ``FetchContent`` module, if a local copy can't be found.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``MIPP::MIPP``

Interface library with MIPP's include directories and sources.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: MIPP_INCLUDE_DIR

Include directory for the MIPP library.
When searching for this path, the environment variable :envvar:`MIPP_INCLUDE_DIR` is added to the search path.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: MIPP_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`MIPP_INCLUDE_DIR` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://github.com/aff3ct/MIPP"
                        DESCRIPTION "Wrapper for various platform-specific SIMD instruction sets")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

find_path (MIPP_INCLUDE_DIR mipp.h PATHS ENV MIPP_INCLUDE_DIR PATH_SUFFIXES src
           DOC "Include directory for the MIPP library")

if (MIPP_INCLUDE_DIR)
    set (mipp_find_location Local)
else ()
    include (FetchContent)

    FetchContent_Declare (MIPP GIT_REPOSITORY "https://github.com/aff3ct/MIPP.git"
                          GIT_TAG "origin/master")

    FetchContent_MakeAvailable (MIPP)

    set (MIPP_INCLUDE_DIR "${mipp_SOURCE_DIR}/src"
         CACHE PATH "Include directory for the MIPP library" FORCE)

    set (mipp_find_location Downloaded)
endif ()

#

add_library (MIPP::MIPP IMPORTED INTERFACE)

target_include_directories (MIPP::MIPP INTERFACE "${MIPP_INCLUDE_DIR}")

target_sources (MIPP::MIPP INTERFACE "${MIPP_INCLUDE_DIR}/mipp.h")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "MIPP found - ${mipp_find_location}"
                      "MIPP - ${mipp_find_location} [${MIPP_INCLUDE_DIR}]")

unset (mipp_find_location)
