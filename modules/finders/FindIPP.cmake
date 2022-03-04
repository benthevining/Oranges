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

#[[

Finds the Intel IPP libraries for signal processing.

Options:
- IPP_STATIC
- IPP_MULTI_THREADED

Targets:
- Intel::IPP : interface library that can be linked to

Output variables:
- IPP_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

find_path (IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
									   /opt/intel/oneapi/ipp/include DOC "Intel IPP root directory")

if(NOT IPP_INCLUDE_DIR OR NOT IS_DIRECTORY "${IPP_INCLUDE_DIR}")
	if(IPP_FIND_REQUIRED)
		message (FATAL_ERROR "IPP could not be located!")
	else()
		if(NOT IPP_FIND_QUIETLY)
			message (WARNING "IPP include directory could not be located!")
		endif()

		set (IPP_FOUND FALSE)
		return ()
	endif()
endif()

set (IPP_ROOT "${IPP_INCLUDE_DIR}/..")

if(NOT IS_DIRECTORY "${IPP_ROOT}")
	if(IPP_FIND_REQUIRED)
		message (FATAL_ERROR "IPP could not be located!")
	else()
		if(NOT IPP_FIND_QUIETLY)
			message (WARNING "IPP root directory could not be located!")
		endif()

		set (IPP_FOUND FALSE)
		return ()
	endif()
endif()

option (IPP_STATIC "Use static IPP libraries" ON)
option (IPP_MULTI_THREADED "Use multithreaded IPP libraries" OFF)

if(IPP_STATIC)
	if(IPP_MULTI_THREADED)
		set (IPP_LIBNAME_SUFFIX _t)
	else()
		set (IPP_LIBNAME_SUFFIX _l)
	endif()

	set (IPP_LIBTYPE_PREFIX "${CMAKE_STATIC_LIBRARY_PREFIX}")
	set (IPP_LIBTYPE_SUFFIX "${CMAKE_STATIC_LIBRARY_SUFFIX}")
else()
	set (IPP_LIBNAME_SUFFIX "")
	set (IPP_LIBTYPE_PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
	set (IPP_LIBTYPE_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

add_library (IntelIPP INTERFACE)

macro(_oranges_find_ipp_library IPP_COMPONENT)

	string (TOLOWER "${IPP_COMPONENT}" IPP_COMPONENT_LOWER)

	set (baseName "${ipp${IPP_COMPONENT_LOWER}${IPP_LIBNAME_SUFFIX}}")

	find_library (
		libName
		NAMES "${baseName}" "${IPP_LIBTYPE_PREFIX}${baseName}"
			  "${IPP_LIBTYPE_PREFIX}${baseName}${IPP_LIBTYPE_SUFFIX}"
			  "${baseName}${IPP_LIBTYPE_SUFFIX}"
		PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
		DOC "Intel IPP ${IPP_COMPONENT} library")

	if(NOT libName)
		if(IPP_FIND_REQUIRED)
			message (FATAL_ERROR "IPP could not be located!")
		else()
			if(NOT IPP_FIND_QUIETLY)
				message (WARNING "IPP component library ${IPP_COMPONENT} could not be located!")
			endif()

			set (IPP_FOUND FALSE)
			return ()
		endif()
	endif()

	target_link_libraries (IntelIPP INTERFACE "${libName}")
endmacro()

_oranges_find_ipp_library (CORE) # Core
_oranges_find_ipp_library (S) # Signal Processing
_oranges_find_ipp_library (VM) # Vector Math

target_include_directories (IntelIPP INTERFACE "${IPP_INCLUDE_DIR}")

add_library (Intel::IPP ALIAS IntelIPP)

set (IPP_FOUND TRUE)
