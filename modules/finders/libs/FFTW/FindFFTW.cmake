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
FFTW produces two separate CMake packages, fftw3 (double precision) and fftw3f (float precision); this find module searches for both and creates an interface target that links to whichever is found (or both).

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- FFTW_FOUND

Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- fftw3 - double precision FFTW library
- fftw3f - single precision FFTW library

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- FFTW::FFTW : interface library that links to both the single and/or double precision libraries, and has the macros FFTW_SINGLE_ONLY or FFTW_DOUBLE_ONLY defined, if applicable.

#]=======================================================================]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (FFTW PROPERTIES URL "https://www.fftw.org" DESCRIPTION "FFT library")

oranges_file_scoped_message_context ("FindFFTW")

set (FFTW_FOUND FALSE)

find_package_default_component_list (fftw3 fftw3f)

if(FFTW_FIND_QUIETLY)
	set (quiet_flag QUIET)
endif()

if(fftw3 IN_LIST FFTW_FIND_COMPONENTS)
	if(FFTW_FIND_REQUIRED_fftw3)
		set (required_flag REQUIRED)
	endif()

	find_package (fftw3 ${quiet_flag} ${required_flag})

	unset (required_flag)
endif()

if(fftw3f IN_LIST FFTW_FIND_COMPONENTS)
	if(FFTW_FIND_REQUIRED_fftw3f)
		set (required_flag REQUIRED)
	endif()

	find_package (fftw3f ${quiet_flag} ${required_flag})

	unset (required_flag)
endif()

unset (quiet_flag)

if(NOT (TARGET FFTW3::fftw3 OR TARGET FFTW3::fftw3f))
	find_package_warning_or_error ("FFTW could not be located!")
	return ()
endif()

if(NOT TARGET FFTW)
	add_library (FFTW INTERFACE)
endif()

target_link_libraries (FFTW INTERFACE $<TARGET_NAME_IF_EXISTS:FFTW3::fftw3>
									  $<TARGET_NAME_IF_EXISTS:FFTW3::fftw3f>)

# TO DO: this will break if this find module is loaded multiple times with different component
# requirements...

if(TARGET FFTW::fftw3 AND NOT TARGET FFTW::fftw3f)
	target_compile_definitions (FFTW INTERFACE FFTW_DOUBLE_ONLY=1)
else()
	target_compile_definitions (FFTW INTERFACE FFTW_DOUBLE_ONLY=0)
endif()

if(TARGET FFTW::fftw3f AND NOT TARGET FFTW::fftw3)
	target_compile_definitions (FFTW INTERFACE FFTW_SINGLE_ONLY=1)
else()
	target_compile_definitions (FFTW INTERFACE FFTW_SINGLE_ONLY=0)
endif()

install (TARGETS FFTW EXPORT FFTWTargets)

install (EXPORT FFTWTargets DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/FFTW" NAMESPACE FFTW::
		 COMPONENT FFTW)

include (CPackComponent)

cpack_add_component (FFTW DESCRIPTION "FFTW FFT library")

if(NOT TARGET FFTW::FFTW)
	add_library (FFTW::FFTW ALIAS FFTW)
endif()

set (FFTW_FOUND TRUE)
