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

FindSampleRate
-------------------------

A find module for libsamplerate.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``SampleRate::samplerate``

The libsamplerate library.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: LIBSAMPLERATE_INCLUDE_DIR

Include directory path for libsamplerate.
When searching for this path, the environment variable :envvar:`LIBSAMPLERATE_INCLUDE_DIR` is added to the search path.


.. cmake:variable:: LIBSAMPLERATE_LIBRARY

Path to the prebuilt binary of the libsamplerate library.
When searching for this file, the environment variable :envvar:`LIBSAMPLERATE_LIBRARY` is added to the search path.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: LIBSAMPLERATE_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`LIBSAMPLERATE_INCLUDE_DIR` path.


.. cmake:envvar:: LIBSAMPLERATE_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`LIBSAMPLERATE_LIBRARY` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "http://libsndfile.github.io/libsamplerate/"
    DESCRIPTION "Resampling library")

find_package (PkgConfig QUIET)

if (PKG_CONFIG_FOUND)
    pkg_search_module (PKGSAMPLERATE QUIET samplerate libsamplerate)
endif ()

find_path (
    LIBSAMPLERATE_INCLUDE_DIR NAMES samplerate.h PATHS ${PKGSAMPLERATE_INCLUDE_DIRS} ENV
                                                       LIBSAMPLERATE_INCLUDE_DIR
    DOC "libsamplerate includes directory")

find_library (
    LIBSAMPLERATE_LIBRARY NAMES samplerate libsamplerate PATHS ${PKGSAMPLERATE_LIBRARY_DIRS} ENV
                                                               LIBSAMPLERATE_LIBRARY
    DOC "libsamplerate library")

mark_as_advanced (LIBSAMPLERATE_INCLUDE_DIR LIBSAMPLERATE_LIBRARY)

if (PKGSAMPLERATE_VERSION)
    set (version_flag VERSION_VAR PKGSAMPLERATE_VERSION HANDLE_VERSION_RANGE)
else ()
    unset (version_flag)
endif ()

find_package_handle_standard_args (
    "${CMAKE_FIND_PACKAGE_NAME}" REQUIRED_VARS LIBSAMPLERATE_INCLUDE_DIR LIBSAMPLERATE_LIBRARY
                                               ${version_flag})

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (SampleRate::samplerate IMPORTED UNKNOWN)

set_target_properties (SampleRate::samplerate PROPERTIES IMPORTED_LOCATION
                                                         "${LIBSAMPLERATE_LIBRARY}")

target_include_directories (SampleRate::samplerate INTERFACE "${LIBSAMPLERATE_INCLUDE_DIR}")

find_package_detect_macos_arch (SampleRate::samplerate "${LIBSAMPLERATE_LIBRARY}")

target_sources (SampleRate::samplerate INTERFACE "${LIBSAMPLERATE_INCLUDE_DIR}/samplerate.h")

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "libsamplerate - found (local)"
                      "[${LIBSAMPLERATE_INCLUDE_DIR}] [${LIBSAMPLERATE_LIBRARY}]")
