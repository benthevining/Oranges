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

Findfftw3
-------------------------

A find module for the FFTW double-precision FFT library.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``FFTW3::fftw3``

FFTW double precision library.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: FFTW_D_INCLUDE_DIR

Include directory path for the FFTW double precision library.
When searching for this path, the environment variable :envvar:`FFTW_D_INCLUDE_DIR` is added to the search path.


.. cmake:variable:: FFTW_D_LIBRARY

Path to the prebuilt binary of the FFTW double precision library.
When searching for this file, the environment variable :envvar:`FFTW_D_LIBRARY` is added to the search path.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: FFTW_D_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`FFTW_D_INCLUDE_DIR` path.


.. cmake:envvar:: FFTW_D_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`FFTW_D_LIBRARY` path.


.. seealso ::

    Module :module:`Findfftw3f`
        A find module for the FFTW float-precision library.

    Module :module:`FindFFTW`
        An aggregate find module for both precisions of FFTW

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://www.fftw.org"
                        DESCRIPTION "Double precision FFT library")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

find_package (PkgConfig QUIET)

if (PKG_CONFIG_FOUND)
    pkg_search_module (PKGFFTWD QUIET fftw3 fftw)
endif ()

find_path (
    FFTW_D_INCLUDE_DIR NAMES fftw3.h dfftw3.h PATHS ${PKGFFTWD_INCLUDE_DIRS} ENV FFTW_D_INCLUDE_DIR
    DOC "FFTW [double] includes directory")

find_library (FFTW_D_LIBRARY NAMES fftw3 dfftw3 PATHS ${PKGFFTWD_LIBRARY_DIRS} ENV FFTW_D_LIBRARY
              DOC "FFTW [double] library")

mark_as_advanced (FFTW_D_INCLUDE_DIR FFTW_D_LIBRARY)

if (PKGFFTWD_VERSION)
    set (version_flag VERSION_VAR PKGFFTWD_VERSION HANDLE_VERSION_RANGE)
else ()
    unset (version_flag)
endif ()

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}"
                                   REQUIRED_VARS FFTW_D_INCLUDE_DIR FFTW_D_LIBRARY ${version_flag})

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (FFTW3::fftw3 IMPORTED UNKNOWN)

set_target_properties (FFTW3::fftw3 PROPERTIES IMPORTED_LOCATION "${FFTW_D_LIBRARY}")

target_include_directories (FFTW3::fftw3 INTERFACE "${FFTW_D_INCLUDE_DIR}")

find_package_detect_macos_arch (FFTW3::fftw3 "${FFTW_D_INCLUDE_DIR}")

target_link_options (FFTW3::fftw3 INTERFACE ${PKGFFTWD_LDFLAGS} ${PKGFFTWD_LDFLAGS_OTHER})

target_compile_options (FFTW3::fftw3 INTERFACE ${PKGFFTWD_CFLAGS} ${PKGFFTWD_CFLAGS_OTHER})

if (EXISTS "${FFTW_D_INCLUDE_DIR}/fftw3.h")
    target_sources (FFTW3::fftw3 INTERFACE "${FFTW_D_INCLUDE_DIR}/fftw3.h")
else ()
    target_sources (FFTW3::fftw3 INTERFACE "${FFTW_D_INCLUDE_DIR}/dfftw3.h")
endif ()

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "FFTW3 [double] - found"
                      "FFTW3 [double] [${FFTW_D_INCLUDE_DIR}] [${FFTW_D_LIBRARY}]")
