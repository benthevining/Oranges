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

FFTW double precision library

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (fftw3 PROPERTIES URL "https://www.fftw.org"
                        DESCRIPTION "double precision FFT library")

oranges_file_scoped_message_context ("Findfftw3")

if (TARGET FFTW3::fftw3)
    set (fftw3_FOUND TRUE)
    return ()
endif ()

set (fftw3_FOUND FALSE)

find_path (FFTW_D_INCLUDES NAMES fftw3.h dfftw3.h DOC "FFTW [double] includes directory")

find_library (FFTW_D_LIBRARIES NAMES fftw3 dfftw3 DOC "FFTW [double] library")

mark_as_advanced (FORCE FFTW_D_INCLUDES FFTW_D_LIBRARIES)

if (FFTW_D_INCLUDES AND FFTW_D_LIBRARIES)
    add_library (fftw3 IMPORTED UNKNOWN)

    set_target_properties (fftw3 PROPERTIES IMPORTED_LOCATION "${FFTW_D_LIBRARIES}")

    target_include_directories (fftw3 INTERFACE "${FFTW_D_INCLUDES}")

    add_library (FFTW3::fftw3 ALIAS fftw3)

    message (DEBUG "FFTW double precision library found")
else ()
    find_package_warning_or_error ("fftw3 could not be located!")
endif ()

set (fftw3_FOUND TRUE)
