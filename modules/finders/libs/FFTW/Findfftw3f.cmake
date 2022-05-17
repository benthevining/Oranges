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

FFTW float precision library

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (fftw3f PROPERTIES URL "https://www.fftw.org"
                        DESCRIPTION "float precision FFT library")

oranges_file_scoped_message_context ("Findfftw3f")

if (TARGET FFTW3::fftw3f)
    set (fftw3f_FOUND TRUE)
    return ()
endif ()

set (fftw3f_FOUND FALSE)

find_path (FFTW_F_INCLUDES NAMES fftw3f.h sfftw3.h DOC "FFTW [float] includes directory")

find_library (FFTW_F_LIBRARIES NAMES fftw3f sfftw3 DOC "FFTW [float] library")

mark_as_advanced (FORCE FFTW_F_INCLUDES FFTW_F_LIBRARIES)

if (FFTW_F_INCLUDES AND FFTW_F_LIBRARIES)
    add_library (fftw3f IMPORTED UNKNOWN)

    set_target_properties (fftw3f PROPERTIES IMPORTED_LOCATION "${FFTW_F_LIBRARIES}")

    target_include_directories (fftw3f INTERFACE "${FFTW_F_INCLUDES}")

    add_library (FFTW3::fftw3f ALIAS fftw3f)

    message (DEBUG "FFTW float precision library found")
else ()
    find_package_warning_or_error ("fftw3f could not be located!")
endif ()

set (fftw3f_FOUND TRUE)
