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

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- FFTW_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- FFTW::FFTW : the FFTW library

#]=======================================================================]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (FFTW PROPERTIES URL "https://www.fftw.org" DESCRIPTION "FFT library")

#

oranges_file_scoped_message_context ("FindFFTW")

set (FFTW_FOUND FALSE)

#

find_package_try_pkgconfig (FFTW::FFTW)

#

find_path (FFTW_INCLUDES fftw3.h)

find_library (FFTW_LIBRARIES NAMES fftw3)

mark_as_advanced (FORCE FFTW_INCLUDES FFTW_LIBRARIES)

if(NOT (FFTW_INCLUDES AND FFTW_LIBRARIES))
	find_package_warning_or_error ("FFTW could not be located!")
	return ()
endif()

add_library (FFTW IMPORTED UNKNOWN)

set_target_properties (FFTW PROPERTIES IMPORTED_LOCATION "${FFTW_LIBRARIES}")

target_include_directories (FFTW PUBLIC "${FFTW_INCLUDES}")

add_library (FFTW::FFTW ALIAS FFTW)

set (FFTW_FOUND TRUE)
