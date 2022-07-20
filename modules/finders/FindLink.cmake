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

FindLink
-----------------

A find module for Ableton Link.

This module first searches for Ableton's provided AbletonLinkConfig.cmake file, and if found, includes it;
if not found, this module searches manually for the include directories.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Ableton::Link``

The Ableton Link library.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: ABLETONLINK_CONFIG_FILE

Path to Ableton Link's AbletonLinkConfig.cmake file.
When searching for this path, the environment variable :envvar:`ABLETONLINK_CONFIG_FILE` is added to the search path.


.. cmake:variable:: ABLETONLINK_INCLUDE_DIR

Include directory path for Ableton Link.
When searching for this path, the environment variable :envvar:`ABLETONLINK_INCLUDE_DIR` is added to the search path.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: ABLETONLINK_CONFIG_FILE

This environment variable, if set, is added to the search path when locating the :variable:`ABLETONLINK_CONFIG_FILE` path.


.. cmake:envvar:: ABLETONLINK_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`ABLETONLINK_INCLUDE_DIR` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES
                        URL "https://github.com/Ableton/link" DESCRIPTION "Tempo sync library")

find_file (ABLETONLINK_CONFIG_FILE NAMES AbletonLinkConfig.cmake PATHS ENV ABLETONLINK_CONFIG_FILE
           DOC "Path to Ableton Link's AbletonLinkConfig.cmake file")

mark_as_advanced (ABLETONLINK_CONFIG_FILE)

if (ABLETONLINK_CONFIG_FILE)
    include ("${ABLETONLINK_CONFIG_FILE}")

    find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "Ableton Link - found (local - config file)"
                          "[${ABLETONLINK_CONFIG_FILE}]")

    return ()
endif ()

find_path (ABLETONLINK_INCLUDE_DIR NAMES Link.hpp PATHS ENV ABLETONLINK_INCLUDE_DIR
           DOC "Ableton Link include directory")

mark_as_advanced (ABLETONLINK_INCLUDE_DIR)

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}"
                                   REQUIRED_VARS ABLETONLINK_INCLUDE_DIR)

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (Ableton::Link IMPORTED INTERFACE)

target_include_directories (Ableton::Link INTERFACE "${ABLETONLINK_INCLUDE_DIR}")

target_sources (Ableton::Link INTERFACE "${ABLETONLINK_INCLUDE_DIR}/Link.hpp")

find_package_message (
    "${CMAKE_FIND_PACKAGE_NAME}" "Ableton Link - found (local - found include directory)"
    "[${ABLETONLINK_INCLUDE_DIR}]")
