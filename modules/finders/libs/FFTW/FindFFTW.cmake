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

FindFFTW
-------------------------

A find module for the FFTW FFT library.
FFTW produces two separate CMake packages, fftw3 (double precision) and fftw3f (float precision);
this find module searches for both and creates an interface target that links to whichever is found (or both).

Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Double - double precision FFTW library
- Float - single precision FFTW library

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``FFTW::FFTW``

Interface library that links to both the single and/or double precision libraries, and has the following macros defined:

- ``FFTW_SINGLE_AVAILABLE`` - 1 if the single-precision library was found, 0 otherwise
- ``FFTW_DOUBLE_AVAILABLE`` - 1 if the double-precision library was found, 0 otherwise
- ``FFTW_SINGLE_ONLY`` - 1 if float precision is available, but not double precision. 0 if both precisions are available.
- ``FFTW_DOUBLE_ONLY`` - 1 if double precision is available, but not single precision. 0 if both precisions are available.

#]=======================================================================]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://www.fftw.org"
                        DESCRIPTION "FFT library")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
set (${CMAKE_FIND_PACKAGE_NAME}_Double_FOUND FALSE)
set (${CMAKE_FIND_PACKAGE_NAME}_Float_FOUND FALSE)

find_package_default_component_list (Double Float)

if (Double IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Double)
        set (required_flag REQUIRED)
    else ()
        unset (required_flag)
    endif ()

    find_package (fftw3 QUIET ${required_flag})

    unset (required_flag)

    set (${CMAKE_FIND_PACKAGE_NAME}_Double_FOUND "${fftw3_FOUND}")

    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Double AND NOT fftw3_FOUND)
        set (${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Double precision library not found")
    endif ()
endif ()

if (Float IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Float)
        set (required_flag REQUIRED)
    else ()
        unset (required_flag)
    endif ()

    find_package (fftw3f QUIET ${required_flag})

    unset (required_flag)

    set (${CMAKE_FIND_PACKAGE_NAME}_Float_FOUND "${fftw3f_FOUND}")

    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Float AND NOT fftw3f_FOUND)
        set (${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Float precision library not found")
    endif ()
endif ()

if (NOT (TARGET FFTW3::fftw3 OR TARGET FFTW3::fftw3f))
    return ()
endif ()

if (NOT TARGET FFTW::FFTW)
    add_library (FFTW::FFTW IMPORTED INTERFACE)
endif ()

target_link_libraries (FFTW::FFTW INTERFACE "$<TARGET_NAME_IF_EXISTS:FFTW3::fftw3>"
                                            "$<TARGET_NAME_IF_EXISTS:FFTW3::fftw3f>")

set (float_lib_exists "$<TARGET_EXISTS:FFTW::fftw3f>")
set (double_lib_exists "$<TARGET_EXISTS:FFTW::fftw3>")

target_compile_definitions (
    FFTW::FFTW
    INTERFACE
        "FFTW_SINGLE_AVAILABLE=${float_lib_exists}"
        "FFTW_DOUBLE_AVAILABLE=${double_lib_exists}"
        "$<$<AND:${double_lib_exists},$<NOT:${float_lib_exists}>>:FFTW_DOUBLE_ONLY=1>"
        "$<$<AND:${float_lib_exists},$<NOT:${double_lib_exists}>>:FFTW_SINGLE_ONLY=1>"
        "$<$<AND:${float_lib_exists},${double_lib_exists}>:FFTW_DOUBLE_ONLY=0;FFTW_SINGLE_ONLY=0>")

unset (float_lib_exists)
unset (double_lib_exists)

if (TARGET FFTW3::fftw3)
    set (fftw_found_comps Double)
endif ()

if (TARGET FFTW3::fftw3f)
    list (APPEND fftw_found_comps Float)
endif ()

if ("${fftw_found_comps}" STREQUAL "${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS}")
    set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
endif ()

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "FFTW - found components ${fftw_found_comps}"
                      "FFTW [${fftw_found_comps}]")

unset (fftw_found_comps)
