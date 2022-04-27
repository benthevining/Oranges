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

Findcpplint
-------------------------

Find the cpplint static analysis tool.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- CPPLINT_IGNORE - list of checks to ignore (accepts regex).
- CPPLINT_VERBOSITY - verbosity level. Defaults to 0.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- cpplint_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Google::cpplint : the cpplint executable
- Google::cpplint-interface : interface library that can be linked against to enable cpplint integrations for a target


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	cpplint PROPERTIES
	URL "https://github.com/google/styleguide"
	DESCRIPTION "C++ code linter"
	TYPE OPTIONAL
	PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findcpplint")

set (
	CPPLINT_IGNORE
	"-whitespace;-legal;-build;-runtime/references;-readability/braces;-readability/todo"
	CACHE STRING "List of cpplint checks to ignore")

set (CPPLINT_VERBOSITY 0 CACHE STRING "cpplint verbosity level")

find_program (PROGRAM_CPPLINT NAMES cpplint DOC "cpplint executable")

mark_as_advanced (FORCE PROGRAM_CPPLINT CPPLINT_IGNORE CPPLINT_VERBOSITY)

set (cpplint_FOUND FALSE)

if (NOT PROGRAM_CPPLINT)
	find_package_warning_or_error ("cpplint program cannot be found!")
	return ()
endif ()

if (NOT cpplint_FIND_QUIETLY)
	message (VERBOSE "Using cpplint!")
endif ()

add_executable (cpplint IMPORTED GLOBAL)

set_target_properties (cpplint PROPERTIES IMPORTED_LOCATION
										  "${PROGRAM_CPPLINT}")

add_executable (Google::cpplint ALIAS cpplint)

set (cpplint_FOUND TRUE)

if (NOT TARGET Google::cpplint-interface)

	add_library (cpplint-interface INTERFACE)

	list (JOIN CPPLINT_IGNORE "," CPPLINT_IGNORE)

	set_target_properties (
		cpplint-interface
		PROPERTIES
			CXX_CPPLINT
			"${PROGRAM_CPPLINT};--verbose=${CPPLINT_VERBOSITY};--filter=${CPPLINT_IGNORE}"
			C_CPPLINT
			"${PROGRAM_CPPLINT};--verbose=${CPPLINT_VERBOSITY};--filter=${CPPLINT_IGNORE}"
		)

	add_library (Google::cpplint-interface ALIAS cpplint-interface)
endif ()
