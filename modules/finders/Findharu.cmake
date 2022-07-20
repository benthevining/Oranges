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

Findharu
-----------------

A find module for the libharu PDF library.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``haru::haru``

The libharu library.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: HARU_INCLUDE_DIR

Include directory path for libharu.
When searching for this path, the environment variable :envvar:`HARU_INCLUDE_DIR` is added to the search path.


.. cmake:variable:: HARU_LIBRARY

Path to the prebuilt binary of the libharu library.
When searching for this file, the environment variable :envvar:`HARU_LIBRARY` is added to the search path.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: HARU_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`HARU_INCLUDE_DIR` path.


.. cmake:envvar:: HARU_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`HARU_LIBRARY` path.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "http://libharu.org/"
                        DESCRIPTION "PDF library")

find_package (PkgConfig QUIET)

if (PKG_CONFIG_FOUND)
    pkg_search_module (PKGHARU QUIET haru libharu)
endif ()

find_path (HARU_INCLUDE_DIR NAMES hpdf.h PATHS ${PKGHARU_INCLUDE_DIRS} ENV HARU_INCLUDE_DIR
           DOC "libharu include directories")

find_library (HARU_LIBRARY NAMES haru libharu PATHS ${PKGHARU_LIBRARY_DIRS} ENV HARU_LIBRARY
              DOC "libharu library")

mark_as_advanced (HARU_INCLUDE_DIR HARU_LIBRARY)

if (PKGHARU_VERSION)
    set (version_flag VERSION_VAR PKGHARU_VERSION HANDLE_VERSION_RANGE)
else ()
    unset (version_flag)
endif ()

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}"
                                   REQUIRED_VARS HARU_INCLUDE_DIR HARU_LIBRARY ${version_flag})

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (haru::haru IMPORTED UNKNOWN)

set_target_properties (haru::haru PROPERTIES IMPORTED_LOCATION "${HARU_LIBRARY}")

target_include_directories (haru::haru INTERFACE "${HARU_INCLUDE_DIR}")

find_package_detect_macos_arch (haru::haru "${HARU_LIBRARY}")

target_link_options (haru::haru INTERFACE ${PKGHARU_LDFLAGS} ${PKGHARU_LDFLAGS_OTHER})

target_compile_options (haru::haru INTERFACE ${PKGHARU_CFLAGS} ${PKGHARU_CFLAGS_OTHER})

target_sources (haru::haru INTERFACE "${HARU_INCLUDE_DIR}/hpdf.h")

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "libharu - found (local)"
                      "[${HARU_INCLUDE_DIR}] [${HARU_LIBRARY}]")
