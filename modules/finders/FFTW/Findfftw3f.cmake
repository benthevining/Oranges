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

Findfftw3f
-------------------------

A find module for the FFTW float-precision FFT library.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``FFTW3::fftw3f``

FFTW float precision library.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: FFTW_F_INCLUDE_DIR

Include directory path for the FFTW float precision library.
When searching for this path, the environment variable :envvar:`FFTW_F_INCLUDE_DIR` is added to the search path.

.. cmake:variable:: FFTW_F_LIBRARY

Path to the prebuilt binary of the FFTW float precision library.
When searching for this file, the environment variable :envvar:`FFTW_F_LIBRARY` is added to the search path.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: FFTW_F_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`FFTW_F_INCLUDE_DIR` path.

.. cmake:envvar:: FFTW_F_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`FFTW_F_LIBRARY` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)
include (FindPackageHandleStandardArgs)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://www.fftw.org"
                        DESCRIPTION "Float precision FFT library")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

find_path (FFTW_F_INCLUDE_DIR NAMES fftw3f.h sfftw3.h PATHS ENV FFTW_F_INCLUDE_DIR
           DOC "FFTW [float] includes directory")

find_library (FFTW_F_LIBRARY NAMES fftw3f sfftw3 PATHS ENV FFTW_F_LIBRARY
              DOC "FFTW [float] library")

mark_as_advanced (FFTW_F_INCLUDE_DIR FFTW_F_LIBRARY)

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}" REQUIRED_VARS FFTW_F_INCLUDE_DIR
                                                                              FFTW_F_LIBRARY)

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (FFTW3::fftw3f IMPORTED UNKNOWN)

set_target_properties (FFTW3::fftw3f PROPERTIES IMPORTED_LOCATION "${FFTW_F_LIBRARY}")

target_include_directories (FFTW3::fftw3f INTERFACE "${FFTW_F_INCLUDE_DIR}")

if (EXISTS "${FFTW_F_INCLUDE_DIR}/fftw3f.h")
    target_sources (FFTW3::fftw3f INTERFACE "${FFTW_F_INCLUDE_DIR}/fftw3f.h")
else ()
    target_sources (FFTW3::fftw3f INTERFACE "${FFTW_F_INCLUDE_DIR}/sfftw3.h")
endif ()

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "FFTW3 [float] - found"
                      "FFTW3 [float] [${FFTW_F_INCLUDE_DIR}] [${FFTW_F_LIBRARY}]")
