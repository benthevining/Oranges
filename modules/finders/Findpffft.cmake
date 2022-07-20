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

Findpffft
-------------------------

A find module for pffft.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``pffft::pffft``

The pffft library.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PFFFT_INCLUDE_DIR

Include directory path for pffft.
When searching for this path, the environment variable :envvar:`PFFFT_INCLUDE_DIR` is added to the search path.


.. cmake:variable:: PFFFT_LIBRARY

Path to the prebuilt binary of the pffft library.
When searching for this file, the environment variable :envvar:`PFFFT_LIBRARY` is added to the search path.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: PFFFT_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`PFFFT_INCLUDE_DIR` path.


.. cmake:envvar:: PFFFT_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`PFFFT_LIBRARY` path.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES
                        URL "https://github.com/marton78/pffft" DESCRIPTION "Optimized FFT library")

find_package (PkgConfig QUIET)

if (PKG_CONFIG_FOUND)
    pkg_check_modules (PKGPFFFT QUIET pffft)
endif ()

find_path (PFFFT_INCLUDE_DIR NAMES pffft.h PATHS ${PKGPFFFT_INCLUDE_DIRS} ENV PFFFT_INCLUDE_DIR
           DOC "pffft includes directory")

find_library (PFFFT_LIBRARY NAMES pffft PFFFT PATHS ${PKGPFFFT_LIBRARY_DIRS} ENV PFFFT_LIBRARY
              DOC "pffft library")

mark_as_advanced (PFFFT_INCLUDE_DIR PFFFT_LIBRARY)

if (PKGPFFFT_VERSION)
    set (version_flag VERSION_VAR PKGPFFFT_VERSION HANDLE_VERSION_RANGE)
else ()
    unset (version_flag)
endif ()

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}"
                                   REQUIRED_VARS PFFFT_INCLUDE_DIR PFFFT_LIBRARY ${version_flag})

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (pffft::pffft IMPORTED UNKNOWN)

set_target_properties (pffft::pffft PROPERTIES IMPORTED_LOCATION "${PFFFT_LIBRARY}")

target_include_directories (pffft::pffft INTERFACE "${PFFFT_INCLUDE_DIR}")

find_package_detect_macos_arch (pffft::pffft "${PFFFT_LIBRARY}")

target_link_options (pffft::pffft INTERFACE ${PKGPFFFT_LDFLAGS} ${PKGPFFFT_LDFLAGS_OTHER})

target_compile_options (pffft::pffft INTERFACE ${PKGPFFFT_CFLAGS} ${PKGPFFFT_CFLAGS_OTHER})

target_sources (pffft::pffft INTERFACE "${PFFFT_INCLUDE_DIR}/pffft.h")

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "pffft - found (local)"
                      "[${PFFFT_INCLUDE_DIR}] [${PFFFT_LIBRARY}]")
