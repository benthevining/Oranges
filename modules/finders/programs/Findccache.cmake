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

Findccache
-------------------------

Find the ccache compiler cache.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ccache_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ccache::ccache : The ccache executable.
- ccache::ccache-interface : Interface library that can be linked against to enable ccache for a target

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (ccache PROPERTIES URL "https://ccache.dev/"
						DESCRIPTION "C/C++ compiler cache")

#

oranges_file_scoped_message_context ("Findccache")

#

define_property (
	TARGET INHERITED PROPERTY ORANGES_USING_CCACHE
	BRIEF_DOCS "Boolean that indicates whether this target is using the ccache compiler cache"
	FULL_DOCS "Boolean that indicates whether this target is using the ccache compiler cache")

set (ccache_FOUND FALSE)

find_program (CCACHE_PROGRAM ccache)

mark_as_advanced (FORCE CCACHE_PROGRAM)

if(NOT CCACHE_PROGRAM)
	find_package_warning_or_error ("ccache program cannot be found!")
	return ()
endif()

if(NOT ccache_FIND_QUIETLY)
	message (VERBOSE "Using ccache!")
endif()

add_executable (ccache IMPORTED GLOBAL)

set_target_properties (ccache PROPERTIES IMPORTED_LOCATION "${CCACHE_PROGRAM}")

add_executable (ccache::ccache ALIAS ccache)

set (ccache_FOUND TRUE)

#

set (CCACHE_OPTIONS "CCACHE_COMPRESS=true;CCACHE_COMPRESSLEVEL=6;CCACHE_MAXSIZE=800M" CACHE STRING
																							"")

mark_as_advanced (FORCE CCACHE_OPTIONS)

list (APPEND CCACHE_OPTIONS "CCACHE_BASEDIR=${CMAKE_SOURCE_DIR}")
list (APPEND CCACHE_OPTIONS "CCACHE_DIR=${CMAKE_SOURCE_DIR}/Cache/ccache/cache")

list (JOIN CCACHE_OPTIONS "\n export " CCACHE_EXPORTS)

#

function(_lemons_configure_compiler_launcher language)

	oranges_add_function_message_context ()

	string (TOUPPER "${language}" lang_upper)

	set (CCACHE_COMPILER_BEING_CONFIGURED "${CMAKE_${lang_upper}_COMPILER}")

	set (script_name "launch-${language}")

	configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/launcher.in" "${script_name}" @ONLY)

	set (${language}_script "${CMAKE_CURRENT_BINARY_DIR}/${script_name}" PARENT_SCOPE)
endfunction()

_lemons_configure_compiler_launcher (c)
_lemons_configure_compiler_launcher (cxx)

unset (CCACHE_EXPORTS)

# TO DO: use cmake for this?
execute_process (COMMAND chmod a+rx "${c_script}" "${cxx_script}")

#

add_library (ccache-interface INTERFACE)

set_target_properties (ccache-interface PROPERTIES ORANGES_USING_CCACHE TRUE)

if(XCODE)
	set (CMAKE_XCODE_ATTRIBUTE_CC "${c_script}")
	set (CMAKE_XCODE_ATTRIBUTE_CXX "${cxx_script}")
	set (CMAKE_XCODE_ATTRIBUTE_LD "${c_script}")
	set (CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}")

	set_target_properties (
		ccache-interface
		PROPERTIES XCODE_ATTRIBUTE_CC "${c_script}" XCODE_ATTRIBUTE_CXX "${cxx_script}"
				   XCODE_ATTRIBUTE_LD "${c_script}" XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}")
else()
	set (CMAKE_C_COMPILER_LAUNCHER "${c_script}")
	set (CMAKE_CXX_COMPILER_LAUNCHER "${cxx_script}")

	set_target_properties (ccache-interface PROPERTIES C_COMPILER_LAUNCHER "${c_script}"
													   CXX_COMPILER_LAUNCHER "${cxx_script}")
endif()

oranges_export_alias_target (ccache-interface ccache)