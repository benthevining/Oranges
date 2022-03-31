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

Findcppcheck
-------------------------

Find the cppcheck static analysis tool.

Cache variables:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- CPPCHECK_ENABLE - list of checks to enable
- CPPCHECK_DISABLE - list of checks to disable

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- cppcheck_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- cppcheck::cppcheck : The cppcheck executable.
- cppcheck::cppcheck-interface : Interface library that can be linked against to enable cppcheck integrations for a target


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (cppcheck PROPERTIES URL "https://cppcheck.sourceforge.io/"
						DESCRIPTION "C++ code linter")

oranges_file_scoped_message_context ("Findcppcheck")

set (CPPCHECK_ENABLE "warning;style;performance;portability"
	 CACHE STRING "List of cppcheck checks to enable")

set (
	CPPCHECK_DISABLE
	"unmatchedSuppression;missingIncludeSystem;unusedStructMember;unreadVariable;preprocessorErrorDirective;unknownMacro"
	CACHE STRING "List of cppcheck checks to disable")

find_program (PROGRAM_CPPCHECK NAMES cppcheck)

mark_as_advanced (FORCE PROGRAM_CPPCHECK CPPCHECK_ENABLE CPPCHECK_DISABLE)

set (cppcheck_FOUND FALSE)

if(NOT PROGRAM_CPPCHECK)
	find_package_warning_or_error ("cppcheck program cannot be found!")
	return ()
endif()

if(NOT cppcheck_FIND_QUIETLY)
	message (VERBOSE "Using cppcheck!")
endif()

add_executable (cppcheck IMPORTED GLOBAL)

set_target_properties (cppcheck PROPERTIES IMPORTED_LOCATION "${PROGRAM_CPPCHECK}")

add_executable (cppcheck::cppcheck ALIAS cppcheck)

set (cppcheck_FOUND TRUE)

set (CMAKE_CXX_CPPCHECK "${PROGRAM_CPPCHECK};--inline-suppr")

foreach(enable_check IN LISTS CPPCHECK_ENABLE)
	list (APPEND CMAKE_CXX_CPPCHECK "--enable=${enable_check}")
endforeach()

foreach(disable_check IN LISTS CPPCHECK_DISABLE)
	list (APPEND CMAKE_CXX_CPPCHECK "--suppress=${disable_check}")
endforeach()

set (CMAKE_CXX_CPPCHECK "${CMAKE_CXX_CPPCHECK}" CACHE STRING "")

mark_as_advanced (FORCE CMAKE_CXX_CPPCHECK)

set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

add_library (cppcheck-interface INTERFACE)

set_target_properties (cppcheck-interface PROPERTIES EXPORT_COMPILE_COMMANDS ON
													 CXX_CPPCHECK "${CMAKE_CXX_CPPCHECK}")

oranges_export_alias_target (cppcheck-interface cppcheck)
