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

OrangesGeneratePlatformHeader
-------------------------

This module provides the function :command:`oranges_generate_platform_header()`.

Generating a platform header for a target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_generate_platform_header

	oranges_generate_platform_header (TARGET <targetName>
									  [BASE_NAME <baseName>]
									  [HEADER <headerName>]
									  [LANGUAGE <languageToUseForTestFeastures>]
									  [INTERFACE]
									  [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>])

Generates a header file containing various platform identifying macros for the current target platform.

The generated file will contain the following macros, where `baseName` is all uppercase and every macro is defined to either 0 or 1 unless otherwise noted:

OS type macros:
<baseName>_UNIX
<baseName>_POSIX
<baseName>_WINDOWS
<baseName>_MINGW
<baseName>_LINUX
<baseName>_APPLE
<baseName>_OSX
<baseName>_IOS
<baseName>_ANDROID
<baseName>_OS_TYPE - a string literal describing the OS type being run. Either 'MacOSX', 'iOS', 'Windows', 'Linux', or 'Android'

Compiler type macros:
<baseName>_CLANG
<baseName>_GCC
<baseName>_MSVC
<baseName>_INTEL_COMPILER
<baseName>_COMPILER_TYPE - a string literal describing the compiler used. Either 'Clang', 'GCC', 'MSVC', 'Intel', or 'Unknown'

Processor and architecture macros:
<baseName>_ARM
<baseName>_INTEL
<baseName>_CPU_TYPE - a string literal describing the CPU. Either 'ARM', 'Intel', or 'Unknown'
<baseName>_32BIT
<baseName>_64BIT
<baseName>_BIG_ENDIAN
<baseName>_LITTLE_ENDIAN

SIMD instruction capabilities
<baseName>_ARM_NEON
<baseName>_AVX
<baseName>_AVX512
<baseName>_SSE

Function force-inline macro
<baseName>_FORCE_INLINE

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

option (ORANGES_DISABLE_SIMD
		"Disable all SIMD macros in generated platform headers (ie, set them all to 0)" OFF)

mark_as_advanced (FORCE ORANGES_DISABLE_SIMD)

#

macro(_oranges_plat_header_set_option inVar cacheVar)
	if(${inVar})
		set (${cacheVar} 1 CACHE INTERNAL "")
	else()
		set (${cacheVar} 0 CACHE INTERNAL "")
	endif()
endmacro()

_oranges_plat_header_set_option (UNIX ORANGES_UNIX)
_oranges_plat_header_set_option (MINGW ORANGES_MINGW)
_oranges_plat_header_set_option (APPLE ORANGES_APPLE)

if(APPLE AND NOT IOS)
	set (ORANGES_MACOSX 1 CACHE INTERNAL "")
	set (ORANGES_OS_TYPE MacOSX CACHE INTERNAL "")
else()
	set (ORANGES_MACOSX 0 CACHE INTERNAL "")
endif()

if(WIN32)
	set (ORANGES_WIN 1 CACHE INTERNAL "")
	set (ORANGES_OS_TYPE Windows CACHE INTERNAL "")
else()
	set (ORANGES_WIN 0 CACHE INTERNAL "")
endif()

if("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
	set (ORANGES_LINUX 1 CACHE INTERNAL "")
	set (ORANGES_OS_TYPE Linux CACHE INTERNAL "")
else()
	set (ORANGES_LINUX 0 CACHE INTERNAL "")
endif()

if(ANDROID)
	set (ORANGES_ANDROID 1 CACHE INTERNAL "")
	set (ORANGES_OS_TYPE Android CACHE INTERNAL "")
else()
	set (ORANGES_ANDROID 0 CACHE INTERNAL "")
endif()

if(IOS)
	set (ORANGES_IOS 1 CACHE INTERNAL "")
	set (ORANGES_OS_TYPE iOS CACHE INTERNAL "")
else()
	set (ORANGES_IOS 0 CACHE INTERNAL "")
endif()

cmake_host_system_information (RESULT is_64_bit QUERY IS_64BIT)

if(is_64_bit)
	set (ORANGES_64BIT 1 CACHE INTERNAL "")
	set (ORANGES_32BIT 0 CACHE INTERNAL "")
else()
	set (ORANGES_64BIT 0 CACHE INTERNAL "")
	set (ORANGES_32BIT 1 CACHE INTERNAL "")
endif()

if(WIN32)
	if("${CMAKE_HOST_SYSTEM_PROCESSOR}" MATCHES "ARM64")
		set (ORANGES_ARM 1 CACHE INTERNAL "")
		set (ORANGES_INTEL 0 CACHE INTERNAL "")
	else()
		set (ORANGES_ARM 0 CACHE INTERNAL "")
		set (ORANGES_INTEL 1 CACHE INTERNAL "")
	endif()
elseif(APPLE)
	if(CMAKE_APPLE_SILICON_PROCESSOR)
		set (_apple_plat_var_to_check CMAKE_APPLE_SILICON_PROCESSOR)
	else()
		set (_apple_plat_var_to_check CMAKE_HOST_SYSTEM_PROCESSOR)
	endif()

	if("${${_apple_plat_var_to_check}}" MATCHES "arm64")
		set (ORANGES_ARM 1 CACHE INTERNAL "")
		set (ORANGES_INTEL 0 CACHE INTERNAL "")
	elseif("${${_apple_plat_var_to_check}}" MATCHES "x86_64")
		set (ORANGES_ARM 0 CACHE INTERNAL "")
		set (ORANGES_INTEL 1 CACHE INTERNAL "")
	endif()

	unset (_apple_plat_var_to_check)
else()
	# ORANGES_ARM, ORANGES_INTEL
endif()

if(ORANGES_ARM)
	set (ORANGES_CPU_TYPE "ARM" CACHE INTERNAL "")
elseif(ORANGES_INTEL)
	set (ORANGES_CPU_TYPE "Intel" CACHE INTERNAL "")
else()
	set (ORANGES_CPU_TYPE "Unknown" CACHE INTERNAL "")
endif()

if(APPLE OR ANDROID OR MINGW OR ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux"))
	set (ORANGES_POSIX 1 CACHE INTERNAL "")
else()
	set (ORANGES_POSIX 0 CACHE INTERNAL "")
endif()

if(MSVC)
	set (ORANGES_FORCE_INLINE "__forceinline" CACHE INTERNAL "")
else()
	set (ORANGES_FORCE_INLINE "inline __attribute__((always_inline))" CACHE INTERNAL "")
endif()

#[[
ORANGES_DEBUG
ORANGES_ARM_NEON
ORANGES_AVX
ORANGES_AVX512
ORANGES_SSE
]]

#

function(oranges_generate_platform_header)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET BASE_NAME HEADER REL_PATH LANGUAGE INSTALL_COMPONENT)

	cmake_parse_arguments (ORANGES_ARG "INTERFACE" "${oneValueArgs}" "" ${ARGN})

	oranges_assert_target_argument_is_target (ORANGES_ARG)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_BASE_NAME)
		set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
	endif()

	string (TOUPPER "${ORANGES_ARG_BASE_NAME}" ORANGES_ARG_BASE_NAME)

	if(NOT ORANGES_ARG_HEADER)
		set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_platform.h")
	endif()

	if(ORANGES_ARG_INTERFACE)
		set (public_vis INTERFACE)
	else()
		set (public_vis PUBLIC)
	endif()

	if(NOT ORANGES_ARG_REL_PATH)
		set (ORANGES_ARG_REL_PATH "${ORANGES_ARG_TARGET}")
	endif()

	if(NOT ORANGES_ARG_LANGUAGE)
		set (ORANGES_ARG_LANGUAGE CXX)
	endif()

	set (compilerID "${CMAKE_${ORANGES_ARG_LANGUAGE}_COMPILER_ID}")

	macro(_oranges_plat_header_compiler_id_opt compiler cacheVar)
		if("${compilerID}" MATCHES "${compiler}")
			set (${cacheVar} 1)
			set (ORANGES_COMPILER_TYPE "${compiler}")
		else()
			set (${cacheVar} 0)
		endif()
	endmacro()

	_oranges_plat_header_compiler_id_opt ("Clang" ORANGES_CLANG)
	_oranges_plat_header_compiler_id_opt ("GNU" ORANGES_GCC)
	_oranges_plat_header_compiler_id_opt ("GCC" ORANGES_GCC)
	_oranges_plat_header_compiler_id_opt ("MSVC" ORANGES_MSVC)
	_oranges_plat_header_compiler_id_opt ("Intel" ORANGES_INTEL_COMPILER)

	if(NOT ORANGES_COMPILER_TYPE)
		set (ORANGES_COMPILER_TYPE "Unknown")
	endif()

	if(CMAKE_${ORANGES_ARG_LANGUAGE}_BYTE_ORDER)
		set (byte_order "${CMAKE_${ORANGES_ARG_LANGUAGE}_BYTE_ORDER}")

		if("${byte_order}" STREQUAL "BIG_ENDIAN")
			set (ORANGES_BIG_ENDIAN 1)
			set (ORANGES_LITTLE_ENDIAN 0)
		elseif("${byte_order}" STREQUAL "LITTLE_ENDIAN")
			set (ORANGES_BIG_ENDIAN 0)
			set (ORANGES_LITTLE_ENDIAN 1)
		else()
			message (WARNING "Cannot detect host byte order for language ${ORANGES_ARG_LANGUAGE}!")
			set (ORANGES_BIG_ENDIAN 1)
			set (ORANGES_LITTLE_ENDIAN 0)
		endif()
	else()
		message (WARNING "Cannot detect host byte order for language ${ORANGES_ARG_LANGUAGE}!")
		set (ORANGES_BIG_ENDIAN 1)
		set (ORANGES_LITTLE_ENDIAN 0)
	endif()

	configure_file ("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/platform_header.h"
					"${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}" @ONLY)

	target_sources (
		"${ORANGES_ARG_TARGET}"
		"${public_vis}"
		$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>
		)

	if(ORANGES_ARG_INSTALL_COMPONENT)
		set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
	endif()

	install (FILES "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}"
			 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}" ${install_component})

	target_include_directories (
		"${ORANGES_ARG_TARGET}" "${public_vis}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction()
