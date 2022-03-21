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
- IPP_STATIC - defaults to on
- IPP_MULTI_THREADED - defaults to off
- IPP_ROOT : this can be manually overridden to provide the path to the root of the IPP installation.

Components:
- All
- CORE
- AC : audio coding
- CC : color conversion
- CH : string processing
- CP : cryptography
- CV : computer vision
- DC : data compression
- DI : data integrity
- GEN : generated functions
- I : image processing
- J : image compression
- R : rendering and 3D data processing
- M : small matrix operations
- S : signal processing
- SC : speech coding
- SR : speech recognition
- VC : video coding
- VM : vector math
Each one produces an imported target named Intel::ipp_lib_<Component>.

Domain             Domain Code  Depends on
----------------------------------------------
Color Conversion   CC           Core, VM, S, I
String Operations  CH           Core, VM, S
Computer Vision    CV           Core, VM, S, I
Data Compression   DC           Core, VM, S
Image Processing   I            Core, VM, S
Signal Processing  S            Core, VM
Vector Math        VM           Core


Targets:
- Intel::IntelIPP : interface library that links to all found component libraries

Output variables:
- IPP_FOUND

]]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	IPP PROPERTIES
	URL "https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html#gs.sd4x9g"
	DESCRIPTION "Hardware-accelerated functions for signal and image processing provided by Intel")

#

macro(_ipp_unset_vars)
	unset (IPP_ROOT)
	unset (IPP_LIBNAME_SUFFIX)
	unset (IPP_LIB_TYPE)
	unset (IPP_LIBTYPE_PREFIX)
	unset (IPP_LIBTYPE_SUFFIX)
endmacro()

cmake_language (DEFER CALL _ipp_unset_vars)

#

oranges_file_scoped_message_context ("FindIPP")

set (IPP_FOUND FALSE)

#

option (IPP_STATIC "Use static IPP libraries" ON)
option (IPP_MULTI_THREADED "Use multithreaded IPP libraries" OFF)

mark_as_advanced (FORCE IPP_STATIC IPP_MULTI_THREADED)

#

find_package_try_pkgconfig (Intel::IntelIPP IntelIPP)

#

find_path (
	IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
								/opt/intel/oneapi/ipp/include "${IPP_ROOT}/include"
	DOC "Intel IPP root directory" NO_DEFAULT_PATH)

mark_as_advanced (FORCE IPP_INCLUDE_DIR)

if(NOT IPP_INCLUDE_DIR OR NOT IS_DIRECTORY "${IPP_INCLUDE_DIR}")
	find_package_warning_or_error ("IPP include directory could not be located!")
	return ()
endif()

set (IPP_ROOT "${IPP_INCLUDE_DIR}/.." CACHE PATH "Path to the root of the Intel IPP installation")

mark_as_advanced (FORCE IPP_ROOT)

if(NOT IS_DIRECTORY "${IPP_ROOT}")
	find_package_warning_or_error ("IPP root directory could not be located!")
	return ()
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

function(_oranges_find_ipp_library IPP_COMPONENT comp_required)

	list (APPEND CMAKE_MESSAGE_CONTEXT "_oranges_find_ipp_library")

	if(TARGET ipp_lib_${IPP_COMPONENT})
		return ()
	endif()

	string (TOLOWER "${IPP_COMPONENT}" IPP_COMPONENT_LOWER)

	set (baseName "ipp${IPP_COMPONENT_LOWER}")

	find_library (
		IPP_LIB_${IPP_COMPONENT}
		NAMES "${baseName}" "${IPP_LIBTYPE_PREFIX}${baseName}"
			  "${IPP_LIBTYPE_PREFIX}${baseName}${IPP_LIBTYPE_SUFFIX}"
			  "${baseName}${IPP_LIBTYPE_SUFFIX}"
		PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
		DOC "Intel IPP ${IPP_COMPONENT} library"
		NO_DEFAULT_PATH)

	mark_as_advanced (FORCE IPP_LIB_${IPP_COMPONENT})

	if(NOT IPP_LIB_${IPP_COMPONENT} OR NOT EXISTS "${IPP_LIB_${IPP_COMPONENT}}")
		if(comp_required)
			find_package_warning_or_error ("IPP component ${IPP_COMPONENT} could not be found!")
		endif()
	endif()

	find_package_message (IPP "IPP - found component library ${IPP_COMPONENT}"
						  "IPP - ${IPP_COMPONENT} - ${IPP_LIBTYPE_PREFIX} - ${IPP_LIBTYPE_SUFFIX}")

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

function(_oranges_find_ipp_component IPP_COMPONENT comp_required)

	list (APPEND CMAKE_MESSAGE_CONTEXT "_oranges_find_ipp_component")

	if("${IPP_COMPONENT}" STREQUAL CC)
		set (comp_dependencies CORE VM S I)
	elseif("${IPP_COMPONENT}" STREQUAL CH)
		set (comp_dependencies CORE VM S)
	elseif("${IPP_COMPONENT}" STREQUAL CV)
		set (comp_dependencies CORE VM S I)
	elseif("${IPP_COMPONENT}" STREQUAL DC)
		set (comp_dependencies CORE VM S)
	elseif("${IPP_COMPONENT}" STREQUAL I)
		set (comp_dependencies CORE VM S)
	elseif("${IPP_COMPONENT}" STREQUAL S)
		set (comp_dependencies CORE VM)
	elseif("${IPP_COMPONENT}" STREQUAL VM)
		set (comp_dependencies CORE)
	else()
		set (comp_dependencies "")
	endif()

	foreach(dep_component IN LISTS comp_dependencies)
		if(NOT TARGET ipp_lib_${dep_component})
			_oranges_find_ipp_component ("${dep_component}" TRUE)
		endif()

		if(NOT TARGET ipp_lib_${dep_component})
			if(NOT IPP_FIND_QUIETLY)
				message (
					WARNING
						"IPP component ${IPP_COMPONENT} is missing dependent IPP component library ${dep_component}!"
					)
			endif()

			return ()
		endif()
	endforeach()

	_oranges_find_ipp_library ("${ipp_component}" "${comp_required}")

endfunction()

#

if(All IN_LIST IPP_FIND_COMPONENTS)
	set (
		IPP_FIND_COMPONENTS
		CORE
		AC
		CC
		CH
		CP
		CV
		DC
		DI
		GEN
		I
		J
		R
		M
		S
		SC
		SR
		VC
		VM)
endif()

foreach(ipp_component ${IPP_FIND_COMPONENTS})

	_oranges_find_ipp_component ("${ipp_component}" "${IPP_FIND_REQUIRED_${ipp_component}}")

	if(IPP_FIND_REQUIRED_${ipp_component} AND NOT TARGET ipp_lib_${ipp_component})
		if(NOT IPP_FIND_QUIETLY)
			message (WARNING "IPP required component ${ipp_component} cannot be found!")
		endif()

		return ()
	endif()
endforeach()

#

if(NOT TARGET IntelIPP)
	find_package_warning_or_error ("Error creating IntelIPP library target!")
	return ()
endif()

#

target_include_directories (IntelIPP INTERFACE $<BUILD_INTERFACE:${IPP_INCLUDE_DIR}>
											   $<INSTALL_INTERFACE:include/IntelIPP>)

oranges_export_alias_target (IntelIPP Intel)

oranges_install_targets (TARGETS IntelIPP EXPORT OrangesTargets COMPONENT_PREFIX Intel)

set (IPP_FOUND TRUE)

find_package_message (IPP "Found IPP - installed on system" "IPP - system")
