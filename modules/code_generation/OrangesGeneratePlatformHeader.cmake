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
									  [REL_PATH <installRelPath>]
									  [LANGUAGE <languageToUseForTestFeastures>]
									  [INTERFACE])

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

option (ORANGES_DISABLE_SIMD
		"Disable all SIMD macros in generated platform headers (ie, set them all to 0)" OFF)

mark_as_advanced (FORCE ORANGES_DISABLE_SIMD)

set (platform_header_input "${CMAKE_CURRENT_LIST_DIR}/scripts/platform_header.h" CACHE INTERNAL "")

#

macro(_oranges_plat_header_set_option inVar cacheVar)
	if(${inVar})
		set (${cacheVar} 1 CACHE INTERNAL "")
	else()
		set (${cacheVar} 0 CACHE INTERNAL "")
	endif()
endmacro()

_oranges_plat_header_set_option (UNIX ORANGES_UNIX)
_oranges_plat_header_set_option (WIN32 ORANGES_WIN)
_oranges_plat_header_set_option (MINGW ORANGES_MINGW)
_oranges_plat_header_set_option (ANDROID ORANGES_ANDROID)
_oranges_plat_header_set_option (APPLE ORANGES_APPLE)
_oranges_plat_header_set_option (IOS ORANGES_IOS)

if(APPLE AND NOT IOS)
	set (ORANGES_MACOSX 1 CACHE INTERNAL "")
else()
	set (ORANGES_MACOSX 0 CACHE INTERNAL "")
endif()

if("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
	set (ORANGES_LINUX 1 CACHE INTERNAL "")
else()
	set (ORANGES_LINUX 0 CACHE INTERNAL "")
endif()

cmake_host_system_information (RESULT is_64_bit QUERY IS_64BIT)

if(is_64_bit)
	set (ORANGES_64BIT 1 CACHE INTERNAL "")
	set (ORANGES_32BIT 0 CACHE INTERNAL "")
else()
	set (ORANGES_64BIT 0 CACHE INTERNAL "")
	set (ORANGES_32BIT 1 CACHE INTERNAL "")
endif()

if(ORANGES_DISABLE_SIMD)
	set (ORANGES_ARM_NEON 0 CACHE INTERNAL "")
	set (ORANGES_AVX 0 CACHE INTERNAL "")
	set (ORANGES_AVX512 0 CACHE INTERNAL "")
	set (ORANGES_SSE 0 CACHE INTERNAL "")
else()
	#[[
ORANGES_ARM_NEON
ORANGES_AVX
ORANGES_AVX512
ORANGES_SSE
]]
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

if(APPLE OR ANDROID OR MINGW OR ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux"))
	set (ORANGES_POSIX 1 CACHE INTERNAL "")
else()
	set (ORANGES_POSIX 0 CACHE INTERNAL "")
endif()

#[[
ORANGES_DEBUG
]]

#

function(oranges_generate_platform_header)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET BASE_NAME HEADER REL_PATH LANGUAGE)

	cmake_parse_arguments (ORANGES_ARG "INTERFACE" "${oneValueArgs}" "" ${ARGN})

	oranges_assert_target_argument_is_target (ORANGES_ARG)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_BASE_NAME)
		set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
	endif()

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
		else()
			set (${cacheVar} 0)
		endif()
	endmacro()

	_oranges_plat_header_compiler_id_opt ("Clang" ORANGES_CLANG)
	_oranges_plat_header_compiler_id_opt ("GNU|GCC" ORANGES_GCC)
	_oranges_plat_header_compiler_id_opt ("MSVC" ORANGES_MSVC)
	_oranges_plat_header_compiler_id_opt ("Intel" ORANGES_INTEL_COMPILER)

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

	configure_file ("${platform_header_input}" "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}"
					@ONLY)

	oranges_add_target_headers (
		TARGET
		"${ORANGES_ARG_TARGET}"
		SCOPE
		"${public_vis}"
		REL_PATH
		"${ORANGES_ARG_REL_PATH}"
		FILES
		"${ORANGES_ARG_HEADER}"
		BINARY_DIR)

	target_include_directories (
		"${ORANGES_ARG_TARGET}" "${public_vis}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
		$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction()