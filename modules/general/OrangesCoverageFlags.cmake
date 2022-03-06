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

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
	message (
		AUTHOR_WARNING
			"Coverage flags are not supported with your current compiler: ${CMAKE_CXX_COMPILER_ID}")
	return ()
endif()

add_library (OrangesCoverageFlags INTERFACE)

target_compile_options (
	OrangesCoverageFlags
	PUBLIC -O0 # no optimization
		   -g # generate debug info
		   --coverage # sets all required flags
	)

target_link_options (OrangesCoverageFlags PUBLIC --coverage)

oranges_export_alias_target (OrangesCoverageFlags Oranges)

oranges_install_targets (TARGETS OrangesCoverageFlags EXPORT OrangesTargets OPTIONAL)
