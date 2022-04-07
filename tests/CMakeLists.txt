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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

enable_testing ()

include (OrangesGenerateExportHeader)
include (OrangesGeneratePlatformHeader)

#
# generate export header

add_library (oranges_export_header_test STATIC EXCLUDE_FROM_ALL )

target_sources (oranges_export_header_test PRIVATE "${CMAKE_CURRENT_LIST_DIR}/exportTestMain.cpp")

oranges_generate_export_header (TARGET oranges_export_header_test BASE_NAME test
								HEADER test_export.h)

add_test (
	NAME Oranges.ExportHeader
	COMMAND "${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target oranges_export_header_test")

#
# generate platform header

add_library (oranges_platform_header_test STATIC EXCLUDE_FROM_ALL )

target_sources (oranges_platform_header_test
				PRIVATE "${CMAKE_CURRENT_LIST_DIR}/platformTestMain.cpp")

oranges_generate_platform_header (TARGET oranges_platform_header_test BASE_NAME test
								  HEADER test_platform.h)

add_test (
	NAME Oranges.PlatformHeader
	COMMAND "${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target oranges_platform_header_test")
