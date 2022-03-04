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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

find_path (IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
									   /opt/intel/oneapi/ipp/include DOC "Intel IPP root directory")

if(NOT IPP_INCLUDE_DIR OR NOT IS_DIRECTORY "${IPP_INCLUDE_DIR}")
	return ()
endif()

set (IPP_ROOT "${IPP_INCLUDE_DIR}/..")

if(NOT IS_DIRECTORY "${IPP_ROOT}")
	return ()
endif()

option (IPP_STATIC "" ON)
option (IPP_MULTI_THREADED "" OFF)

if(IPP_STATIC)
	if(IPP_MULTI_THREADED)
		set (IPP_LIBNAME_SUFFIX _t)
	else()
		set (IPP_LIBNAME_SUFFIX _l)
	endif()
else()
	set (IPP_LIBNAME_SUFFIX "")
endif()

add_library (IntelIPP INTERFACE)

function(_oranges_find_ipp_library IPP_COMPONENT)
	string (TOLOWER "${IPP_COMPONENT}" IPP_COMPONENT_LOWER)

	set (baseName "${ipp${IPP_COMPONENT_LOWER}${IPP_LIBNAME_SUFFIX}}")

	set (lib_names "${baseName}")

	if(IPP_STATIC)
		list (APPEND lib_names "${CMAKE_STATIC_LIBRARY_PREFIX}${baseName}")
		list (APPEND lib_names
			  "${CMAKE_STATIC_LIBRARY_PREFIX}${baseName}${CMAKE_STATIC_LIBRARY_SUFFIX}")
		list (APPEND lib_names "${baseName}${CMAKE_STATIC_LIBRARY_SUFFIX}")
	else()
		list (APPEND lib_names "${CMAKE_SHARED_LIBRARY_PREFIX}${baseName}")
		list (APPEND lib_names
			  "${CMAKE_SHARED_LIBRARY_PREFIX}${baseName}${CMAKE_SHARED_LIBRARY_SUFFIX}")
		list (APPEND lib_names "${baseName}${CMAKE_SHARED_LIBRARY_SUFFIX}")
	endif()

	find_library (
		"IPP_LIB_${IPP_COMPONENT}" NAMES ${lib_names} PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
		DOC "Intel IPP ${IPP_COMPONENT} library")

	target_link_libraries (IntelIPP INTERFACE "${IPP_LIB_${IPP_COMPONENT}}")
endfunction()

_oranges_find_ipp_library (CORE) # Core
_oranges_find_ipp_library (S) # Signal Processing
_oranges_find_ipp_library (VM) # Vector Math

target_include_directories (IntelIPP INTERFACE "${IPP_INCLUDE_DIR}")

add_library (Intel::IPP ALIAS IntelIPP)
