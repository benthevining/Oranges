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

FindNE10
-------------------------

A find module for NE10.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- NE10::NE10

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: NE10_INCLUDE_DIR

Include directory path for NE10.
When searching for this path, the environment variable :envvar:`NE10_INCLUDE_DIR` is added to the search path.

.. cmake:variable:: NE10_LIBRARY

Path to the prebuilt binary of the NE10 library.
When searching for this file, the environment variable :envvar:`NE10_LIBRARY` is added to the search path.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: NE10_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`NE10_INCLUDE_DIR` path.

.. cmake:envvar:: NE10_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`NE10_LIBRARY` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)
include (FindPackageHandleStandardArgs)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://github.com/projectNe10/Ne10"
    DESCRIPTION "ARM NEON math library")

find_path (NE10_INCLUDE_DIR NAMES NE10.h PATHS ENV NE10_INCLUDE_DIR DOC "NE10 includes directory")

find_library (NE10_LIBRARY NAMES NE10 PATHS ENV NE10_LIBRARY DOC "NE10 library")

mark_as_advanced (FORCE NE10_INCLUDE_DIR NE10_LIBRARY)

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}" REQUIRED_VARS NE10_INCLUDE_DIR
                                                                              NE10_LIBRARY)

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (NE10::NE10 IMPORTED UNKNOWN)

set_target_properties (NE10::NE10 PROPERTIES IMPORTED_LOCATION "${NE10_LIBRARY}")

target_include_directories (NE10::NE10 INTERFACE "${NE10_INCLUDE_DIR}")

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "NE10 - found (local)"
                      "[${NE10_INCLUDE_DIR}] [${NE10_LIBRARY}]")
