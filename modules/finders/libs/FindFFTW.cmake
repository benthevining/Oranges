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

Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- fftw3 - double precision FFTW library
- fftw3f - single precision FFTW library

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- FFTW::fftw3 - double precision library, if found
- FFTW::fftw3f - single precision library, if found
- FFTW::FFTW : interface library that links to both the single and/or double precision libraries, and has the macros FFTW_SINGLE_ONLY or FFTW_DOUBLE_ONLY defined, if applicable.

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

find_package_default_component_list (fftw3 fftw3f)

#

if(NOT TARGET fftw3)
	if(fftw3 IN_LIST FFTW_FIND_COMPONENTS)
		find_path (FFTW_D_INCLUDES NAMES fftw3.h dfftw3.h)

		find_library (FFTW_D_LIBRARIES NAMES fftw3 dfftw)

		mark_as_advanced (FORCE FFTW_D_INCLUDES FFTW_D_LIBRARIES)

		if(FFTW_D_INCLUDES AND FFTW_D_LIBRARIES)
			add_library (fftw3 IMPORTED UNKNOWN)

			set_target_properties (fftw3 PROPERTIES IMPORTED_LOCATION "${FFTW_D_LIBRARIES}")

			target_include_directories (fftw3 PUBLIC "${FFTW_D_INCLUDES}")

			add_library (FFTW::fftw3 ALIAS fftw3)
		else()
			find_package_warning_or_error ("fftw3 could not be located!")
		endif()
	endif()
endif()

if(NOT TARGET fftw3f)
	if(fftw3f IN_LIST FFTW_FIND_COMPONENTS)
		find_path (FFTW_F_INCLUDES NAMES fftw3f.h sfftw3.h)

		find_library (FFTW_F_LIBRARIES NAMES fftw3f sfftw)

		mark_as_advanced (FORCE FFTW_F_INCLUDES FFTW_F_LIBRARIES)

		if(FFTW_F_INCLUDES AND FFTW_F_LIBRARIES)
			add_library (fftw3f IMPORTED UNKNOWN)

			set_target_properties (fftw3f PROPERTIES IMPORTED_LOCATION "${FFTW_F_LIBRARIES}")

			target_include_directories (fftw3f PUBLIC "${FFTW_F_INCLUDES}")

			add_library (FFTW::fftw3f ALIAS fftw3f)
		else()
			find_package_warning_or_error ("fftw3f could not be located!")
		endif()
	endif()
endif()

#

if(NOT (TARGET fftw3 OR TARGET fftw3f))
	find_package_warning_or_error (
		"Neither single or double precision FFTW library could be found!")
	return ()
endif()

#

if(NOT TARGET FFTW)
	add_library (FFTW INTERFACE)
endif()

target_link_libraries (FFTW INTERFACE $<TARGET_NAME_IF_EXISTS:FFTW::fftw3>
									  $<TARGET_NAME_IF_EXISTS:FFTW::fftw3f>)

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

if(NOT TARGET FFTW::FFTW)
	add_library (FFTW::FFTW ALIAS FFTW)
endif()

set (FFTW_FOUND TRUE)
