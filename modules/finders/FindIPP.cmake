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
- IPP_ROOT : this can be manually overridden to provide the path to the root of the IPP installation.

Components:
- CORE
- S : signal processing
- VM : vector math
Each one produces an imported target named Intel::ipp_lib_<Component>.

Targets:
- Intel::IntelIPP : interface library that links to all found component libraries

Output variables:
- IPP_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

find_package (PkgConfig)

pkg_search_module (IPP QUIET IMPORTED_TARGET IPP IntelIPP)

if(IPP_FOUND AND TARGET PkgConfig::IPP)
	add_library (Intel::IntelIPP ALIAS PkgConfig::IPP)

	set (IPP_FOUND TRUE)
	return ()
endif()

option (IPP_STATIC "Use static IPP libraries" ON)
option (IPP_MULTI_THREADED "Use multithreaded IPP libraries" OFF)

mark_as_advanced (FORCE IPP_STATIC IPP_MULTI_THREADED)

#

include (LemonsCmakeDevTools)

set (IPP_FOUND FALSE)

find_path (
	IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
								/opt/intel/oneapi/ipp/include "${IPP_ROOT}/include"
	DOC "Intel IPP root directory")

mark_as_advanced (FORCE IPP_INCLUDE_DIR)

if(NOT IPP_INCLUDE_DIR OR NOT IS_DIRECTORY "${IPP_INCLUDE_DIR}")
	if(IPP_FIND_REQUIRED)
		message (FATAL_ERROR "IPP could not be located!")
	else()
		if(NOT IPP_FIND_QUIETLY)
			message (WARNING "IPP include directory could not be located!")
		endif()

		return ()
	endif()
endif()

set (IPP_ROOT "${IPP_INCLUDE_DIR}/.." CACHE PATH "Path to the root of the Intel IPP installation")

if(NOT IS_DIRECTORY "${IPP_ROOT}")
	if(IPP_FIND_REQUIRED)
		message (FATAL_ERROR "IPP could not be located!")
	else()
		if(NOT IPP_FIND_QUIETLY)
			message (WARNING "IPP root directory could not be located!")
		endif()

		return ()
	endif()
endif()

#

if(IPP_STATIC)
	if(IPP_MULTI_THREADED)
		set (IPP_LIBNAME_SUFFIX _t)
	else()
		set (IPP_LIBNAME_SUFFIX _l)
	endif()

	set (IPP_LIB_TYPE STATIC)
else()
	set (IPP_LIBNAME_SUFFIX "")

	set (IPP_LIB_TYPE SHARED)
endif()

set (IPP_LIBTYPE_PREFIX "${CMAKE_${IPP_LIB_TYPE}_LIBRARY_PREFIX}")
set (IPP_LIBTYPE_SUFFIX "${CMAKE_${IPP_LIB_TYPE}_LIBRARY_SUFFIX}")

#

function(_oranges_find_ipp_library IPP_COMPONENT comp_required result_var)

	string (TOLOWER "${IPP_COMPONENT}" IPP_COMPONENT_LOWER)

	set (baseName "ipp${IPP_COMPONENT_LOWER}")

	find_library (
		IPP_LIB_${IPP_COMPONENT}
		NAMES "${baseName}" "${IPP_LIBTYPE_PREFIX}${baseName}"
			  "${IPP_LIBTYPE_PREFIX}${baseName}${IPP_LIBTYPE_SUFFIX}"
			  "${baseName}${IPP_LIBTYPE_SUFFIX}"
		PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
		DOC "Intel IPP ${IPP_COMPONENT} library")

	mark_as_advanced (FORCE IPP_LIB_${IPP_COMPONENT})

	if(NOT IPP_LIB_${IPP_COMPONENT} OR NOT EXISTS "${IPP_LIB_${IPP_COMPONENT}}")
		if(IPP_FIND_REQUIRED)
			message (FATAL_ERROR "IPP component ${IPP_COMPONENT} could not be found!")
		endif()

		if(NOT IPP_FIND_QUIETLY)
			message (WARNING "IPP component ${IPP_COMPONENT} could not be found!")
		endif()

		if(comp_required)
			set (${result_var} FALSE PARENT_SCOPE)
			return ()
		endif()
	endif()

	set (${result_var} TRUE PARENT_SCOPE)

	add_library (ipp_lib_${IPP_COMPONENT} IMPORTED ${IPP_LIB_TYPE})

	set_target_properties (ipp_lib_${IPP_COMPONENT} PROPERTIES IMPORTED_LOCATION
															   "${IPP_LIB_${IPP_COMPONENT}}")

	oranges_export_alias_target (ipp_lib_${IPP_COMPONENT} Intel)

	if(NOT TARGET IntelIPP)
		add_library (IntelIPP INTERFACE)
	endif()

	target_link_libraries (IntelIPP INTERFACE Intel::ipp_lib_${IPP_COMPONENT})
endfunction()

#

foreach(ipp_component ${IPP_FIND_COMPONENTS})
	_oranges_find_ipp_library ("${ipp_component}" "${IPP_FIND_REQUIRED_${IPP_COMPONENT}}" result)

	if(IPP_FIND_REQUIRED_${IPP_COMPONENT} AND NOT result)
		return ()
	endif()

	# process all this component's comp dependencies...
endforeach()

#

if(NOT TARGET IntelIPP)
	if(IPP_FIND_REQUIRED)
		message (FATAL_ERROR "Error creating IntelIPP library target!")
	endif()

	if(NOT IPP_FIND_QUIETLY)
		message (WARNING "Error creating IntelIPP library target!")
	endif()

	return ()
endif()

#

target_include_directories (IntelIPP INTERFACE $<BUILD_INTERFACE:${IPP_INCLUDE_DIR}>
											   $<INSTALL_INTERFACE:include/IntelIPP>)

oranges_install_targets (TARGETS IntelIPP EXPORT OrangesTargets)

oranges_export_alias_target (IntelIPP Intel)

set (IPP_FOUND TRUE)
# set (IPP_DIR "${IPP_ROOT}")
