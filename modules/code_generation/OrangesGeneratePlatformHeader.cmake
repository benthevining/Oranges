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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

option (ORANGES_DISABLE_SIMD
		"Disable all SIMD macros in generated platform headers (ie, set them all to 0)" OFF)

mark_as_advanced (FORCE ORANGES_DISABLE_SIMD)

set (platform_header_input "${CMAKE_CURRENT_LIST_DIR}/scripts/platform_header.h" CACHE INTERNAL "")

#

function(oranges_generate_platform_header)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET BASE_NAME HEADER REL_PATH)

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

	#[[
	ORANGES_POSIX
	ORANGES_LINUX
	ORANGES_BSD
	ORANGES_ARM
	ORANGES_INTEL
	ORANGES_BIG_ENDIAN
	ORANGES_LITTLE_ENDIAN
	ORANGES_DEBUG
	]]

	if(UNIX)
		set (ORANGES_UNIX 1)
	else()
		set (ORANGES_UNIX 0)
	endif()

	if(WIN32)
		set (ORANGES_WIN 1)
	else()
		set (ORANGES_WIN 0)
	endif()

	if(ANDROID)
		set (ORANGES_ANDROID 1)
	else()
		set (ORANGES_ANDROID 0)
	endif()

	if(APPLE)
		set (ORANGES_APPLE 1)
	else()
		set (ORANGES_APPLE 0)
	endif()

	if(IOS)
		set (ORANGES_IOS 1)
	else()
		set (ORANGES_IOS 0)
	endif()

	if(APPLE AND NOT IOS)
		set (ORANGES_MACOSX 1)
	else()
		set (ORANGES_MACOSX 0)
	endif()

	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang|AppleClang")
		set (ORANGES_CLANG 1)
	else()
		set (ORANGES_CLANG 0)
	endif()

	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU|GCC")
		set (ORANGES_GCC 1)
	else()
		set (ORANGES_GCC 0)
	endif()

	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")
		set (ORANGES_MSVC 1)
	else()
		set (ORANGES_MSVC 0)
	endif()

	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel")
		set (ORANGES_INTEL_COMPILER 1)
	else()
		set (ORANGES_INTEL_COMPILER 0)
	endif()

	cmake_host_system_information (RESULT is_64_bit QUERY IS_64BIT)

	if(is_64_bit)
		set (ORANGES_64BIT 1)
		set (ORANGES_32BIT 0)
	else()
		set (ORANGES_64BIT 0)
		set (ORANGES_32BIT 1)
	endif()

	if(ORANGES_DISABLE_SIMD)
		set (ORANGES_ARM_NEON 0)
		set (ORANGES_AVX 0)
		set (ORANGES_AVX512 0)
		set (ORANGES_SSE 0)
	else()

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
