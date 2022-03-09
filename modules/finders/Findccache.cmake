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

include (FeatureSummary)

set_package_properties (ccache PROPERTIES URL "https://ccache.dev/"
						DESCRIPTION "C/C++ compiler cache")

set (ccache_FOUND FALSE)

find_program (ORANGES_CCACHE ccache)

mark_as_advanced (FORCE ORANGES_CCACHE)

if(NOT ORANGES_CCACHE)
	if(ccache_FIND_REQUIRED)
		message (FATAL_ERROR "ccache program cannot be found!")
	endif()

	return ()
endif()

add_executable (ccache IMPORTED GLOBAL)

set_target_properties (ccache PROPERTIES IMPORTED_LOCATION "${ORANGES_CCACHE}")

add_executable (ccache::ccache ALIAS ccache)

set (ccache_FOUND TRUE)
