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

Findinclude-what-you-use
-------------------------

Find the include-what-you-use static analysis tool.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- include-what-you-use_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Google::include-what-you-use : include-what-you-use executable
- Google::include-what-you-use-interface : interface library that can be linked against to enable include-what-you-use integrations for a target


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	include-what-you-use PROPERTIES
	URL "https://include-what-you-use.org/"
	DESCRIPTION "Static analysis for C++ includes"
	TYPE OPTIONAL
	PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findinclude-what-you-use")

set (include-what-you-use_FOUND FALSE)

find_program (PROGRAM_INCLUDE_WHAT_YOU_USE NAMES include-what-you-use iwyu)

mark_as_advanced (FORCE PROGRAM_INCLUDE_WHAT_YOU_USE)

if(NOT PROGRAM_INCLUDE_WHAT_YOU_USE)
	find_package_warning_or_error ("include-what-you-use program cannot be found!")
	return ()
endif()

if(NOT include-what-you-use_FIND_QUIETLY)
	message (VERBOSE "Using include-what-you-use!")
endif()

add_executable (include-what-you-use IMPORTED GLOBAL)

set_target_properties (include-what-you-use PROPERTIES IMPORTED_LOCATION
													   "${PROGRAM_INCLUDE_WHAT_YOU_USE}")

add_executable (Google::include-what-you-use ALIAS include-what-you-use)

set (include-what-you-use_FOUND TRUE)

set (CMAKE_CXX_INCLUDE_WHAT_YOU_USE
	 "${PROGRAM_INCLUDE_WHAT_YOU_USE};-Xiwyu;--update_comments;-Xiwyu;--cxx17ns" CACHE STRING "")

mark_as_advanced (FORCE CMAKE_CXX_INCLUDE_WHAT_YOU_USE)

add_library (include-what-you-use-interface INTERFACE)

set_target_properties (include-what-you-use-interface
					   PROPERTIES CXX_INCLUDE_WHAT_YOU_USE "${CMAKE_CXX_INCLUDE_WHAT_YOU_USE}")

if(NOT TARGET Google::include-what-you-use-interface)
	add_library (Google::include-what-you-use-interface ALIAS include-what-you-use-interface)
endif()
