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

install_fftw.cmake
-------------------------

This script is intended to be invoked with cmake -P. It builds and installs FFTW to your system.

Input variables (define with -D)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- SOURCE_DIR - path to the root of the FFTW source tree. If not defined, FFTW sources will be downloaded.
- CACHE_DIR - directory to use to cache downloaded sources. If not specified, defaults to <scriptDir>/temp

#]=======================================================================]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if(NOT SOURCE_DIR)

	message (STATUS "Downloading FFTW sources...")

	if(NOT CACHE_DIR)
		set (CACHE_DIR "${CMAKE_CURRENT_LIST_DIR}/temp")
	endif()

	message (STATUS "Cache dir: ${CACHE_DIR}")

	set (tarball "${CACHE_DIR}/fftw-3.3.10.tar.gz")

	file (DOWNLOAD "https://www.fftw.org/fftw-3.3.10.tar.gz" "${tarball}" SHOW_PROGRESS)

	set (SOURCE_DIR "${CACHE_DIR}/FFTW")

	file (ARCHIVE_EXTRACT INPUT "${tarball}" DESTINATION "${CACHE_DIR}")

	set (SOURCE_DIR "${CACHE_DIR}/fftw-3.3.10")

endif()

#

include (ProcessorCount)

ProcessorCount (numCores)

if(numCores EQUAL 0)
	set (numCores 4)
endif()

find_program (SUDO_PROGRAM NAMES sudo)

# ENABLE_AVX, ENABLE_AVX2

cmake_host_system_information (RESULT has_sse QUERY HAS_SSE)

if(has_sse)
	set (sse_flag -D ENABLE_SSE=ON)
endif()

cmake_host_system_information (RESULT has_sse2 QUERY HAS_SSE2)

if(has_sse2)
	set (sse2_flag -D ENABLE_SSE2=ON)
endif()

#

function(install_fftw_library buildDir isFloat)

	if(IS_DIRECTORY "${buildDir}")
		file (REMOVE_RECURSE "${buildDir}")
	else()
		file (MAKE_DIRECTORY "${buildDir}")
	endif()

	if(isFloat)
		set (float_flag -D ENABLE_FLOAT=ON)
	endif()

	execute_process (
		COMMAND "${CMAKE_COMMAND}" -B "${buildDir}" -D BUILD_SHARED_LIBS=OFF -D BUILD_TESTS=OFF
				--log-level=VERBOSE ${float_flag} ${sse_flag} ${sse2_flag}
		WORKING_DIRECTORY "${SOURCE_DIR}" COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

	execute_process (COMMAND "${CMAKE_COMMAND}" --build "${buildDir}" --parallel "${numCores}"
							 COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

	execute_process (COMMAND ${SUDO_PROGRAM} "${CMAKE_COMMAND}" --install "${buildDir}"
							 COMMAND_ECHO STDOUT COMMAND_ERROR_IS_FATAL ANY)

endfunction()

#

message (STATUS "Installing double precision library...")

install_fftw_library ("${SOURCE_DIR}/Builds/double" FALSE)

message (STATUS "Installing float precision library...")

install_fftw_library ("${SOURCE_DIR}/Builds/float" TRUE)

file (REMOVE_RECURSE "${SOURCE_DIR}/Builds")
