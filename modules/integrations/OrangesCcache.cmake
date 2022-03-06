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

include (OrangesAllIntegrations)
include (LemonsCmakeDevTools)

find_program (CCACHE_PROGRAM ccache)

mark_as_advanced (FORCE CCACHE_PROGRAM)

if(NOT CCACHE_PROGRAM)
	message (VERBOSE "ccache could not be found.")
	return ()
endif()

message (STATUS " -- Using ccache! -- ")

set (ccache_options "CCACHE_BASEDIR=${PROJECT_SOURCE_DIR}")

if(DEFINED ENV{CPM_SOURCE_CACHE})
	list (APPEND ccache_options "CCACHE_DIR=$ENV{CPM_SOURCE_CACHE}/ccache/cache")
else()
	list (APPEND ccache_options "CCACHE_DIR=${PROJECT_SOURCE_DIR}/Cache/ccache/cache")
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

add_library (OrangesCcache INTERFACE)

if(XCODE)
	set (CMAKE_XCODE_ATTRIBUTE_CC "${c_script}")
	set (CMAKE_XCODE_ATTRIBUTE_CXX "${cxx_script}")
	set (CMAKE_XCODE_ATTRIBUTE_LD "${c_script}")
	set (CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}")

	set_target_properties (
		OrangesCcache
		PROPERTIES XCODE_ATTRIBUTE_CC "${c_script}" XCODE_ATTRIBUTE_CXX "${cxx_script}"
				   XCODE_ATTRIBUTE_LD "${c_script}" XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}")
else()
	set (CMAKE_C_COMPILER_LAUNCHER "${c_script}")
	set (CMAKE_CXX_COMPILER_LAUNCHER "${cxx_script}")

	set_target_properties (OrangesCcache PROPERTIES C_COMPILER_LAUNCHER "${c_script}"
													CXX_COMPILER_LAUNCHER "${cxx_script}")
endif()

oranges_export_alias_target (OrangesCcache Oranges)

target_link_libraries (OrangesAllIntegrations INTERFACE Oranges::OrangesCcache)

oranges_install_targets (TARGETS OrangesCcache EXPORT OrangesTargets OPTIONAL)
