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
Configures the ccache compiler cache for use with CMake projects.

## Include-time actions:
Configures a compiler-launcher script that uses ccache to execute CMake's generated compiler command line. Does nothing if ccache cannot be located at configure-time.

## Note

If the `LEMONS_ENABLE_INTEGRATIONS` option is ON, then this module will be included by Lemons, when Lemons is added as a subdirectory.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

find_program (CCACHE_PROGRAM ccache)

if(NOT CCACHE_PROGRAM)
	message (VERBOSE "ccache could not be found.")

	function(lemons_use_ccache_for_target)

	endfunction()

	return ()
endif()

if(Lemons_SOURCE_DIR)
	set (ccache_options "CCACHE_BASEDIR=${Lemons_SOURCE_DIR}")
else()
	set (ccache_options "CCACHE_BASEDIR=${CMAKE_SOURCE_DIR}")
endif()

if(DEFINED ENV{CPM_SOURCE_CACHE})
	list (APPEND ccache_options "CCACHE_DIR=$ENV{CPM_SOURCE_CACHE}/ccache/cache")
else()
	list (APPEND ccache_options "CCACHE_DIR=${CCACHE_BASEDIR}/Cache/ccache/cache")
endif()

list (APPEND ccache_options "CCACHE_COMPRESS=true" "CCACHE_COMPRESSLEVEL=6" "CCACHE_MAXSIZE=800M")

list (JOIN ccache_options "\n export " CCCACHE_EXPORTS)

#

function(_lemons_configure_compiler_launcher language)

	string (TOUPPER "${language}" lang_upper)

	set (CCACHE_COMPILER_BEING_CONFIGURED "${CMAKE_${lang_upper}_COMPILER}")

	set (script_name "launch-${language}")

	configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/launcher.in" "${script_name}")

	set (${language}_script "${CMAKE_CURRENT_BINARY_DIR}/${script_name}" PARENT_SCOPE)
endfunction()

_lemons_configure_compiler_launcher (c)
_lemons_configure_compiler_launcher (cxx)

execute_process (COMMAND chmod a+rx "${c_script}" "${cxx_script}")

#

if(XCODE)
	set (CMAKE_XCODE_ATTRIBUTE_CC "${c_script}" CACHE INTERNAL "")
	set (CMAKE_XCODE_ATTRIBUTE_CXX "${cxx_script}" CACHE INTERNAL "")
	set (CMAKE_XCODE_ATTRIBUTE_LD "${c_script}" CACHE INTERNAL "")
	set (CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}" CACHE INTERNAL "")
else()
	set (CMAKE_C_COMPILER_LAUNCHER "${c_script}" CACHE INTERNAL "")
	set (CMAKE_CXX_COMPILER_LAUNCHER "${cxx_script}" CACHE INTERNAL "")
endif()

set (LEMONS_C_COMPILER_LAUNCHER "${c_script}" CACHE INTERNAL "")
set (LEMONS_CXX_COMPILER_LAUNCHER "${cxx_script}" CACHE INTERNAL "")

message (STATUS " -- Using ccache! -- ")

function(lemons_use_ccache_for_target target)

	if(NOT TARGET "${target}")
		message (
			FATAL_ERROR
				"Function ${CMAKE_CURRENT_FUNCTION} called with nonexistent target ${target}!")
	endif()

	if(LEMONS_C_COMPILER_LAUNCHER AND LEMONS_CXX_COMPILER_LAUNCHER)
		set_target_properties (
			"${target}"
			PROPERTIES C_COMPILER_LAUNCHER "${LEMONS_C_COMPILER_LAUNCHER}"
					   CXX_COMPILER_LAUNCHER "${LEMONS_CXX_COMPILER_LAUNCHER}"
					   XCODE_ATTRIBUTE_CC "${LEMONS_C_COMPILER_LAUNCHER}"
					   XCODE_ATTRIBUTE_CXX "${LEMONS_CXX_COMPILER_LAUNCHER}"
					   XCODE_ATTRIBUTE_LD "${LEMONS_C_COMPILER_LAUNCHER}"
					   XCODE_ATTRIBUTE_LDPLUSPLUS "${LEMONS_CXX_COMPILER_LAUNCHER}")
	endif()
endfunction()
