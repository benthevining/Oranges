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

Findclang-tidy
-------------------------

Find the clang-tidy static analysis tool.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- clang-tidy_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Clang::clang-tidy : The clang-tidy executable.
- Clang::clang-tidy-interface : Interface library that can be linked against to enable clang-tidy integrations for a target.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	clang-tidy PROPERTIES
	URL "https://clang.llvm.org/extra/clang-tidy/"
	DESCRIPTION "C++ code linter"
	TYPE OPTIONAL
	PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findclang-tidy")

set (clang-tidy_FOUND FALSE)

find_program (PROGRAM_CLANG_TIDY "clang-tidy" DOC "clang-tidy executable")

mark_as_advanced (FORCE PROGRAM_CLANG_TIDY)

if (NOT PROGRAM_CLANG_TIDY)
	find_package_warning_or_error ("clang-tidy program cannot be found!")
	return ()
endif ()

if (NOT clang-tidy_FIND_QUIETLY)
	message (VERBOSE "Using clang-tidy!")
endif ()

add_executable (clang-tidy IMPORTED GLOBAL)

set_target_properties (clang-tidy PROPERTIES IMPORTED_LOCATION
											 "${PROGRAM_CLANG_TIDY}")

add_executable (Clang::clang-tidy ALIAS clang-tidy)

set (clang-tidy_FOUND TRUE)

if (NOT TARGET Clang::clang-tidy-interface)

	add_library (clang-tidy-interface INTERFACE)

	set_target_properties (
		clang-tidy-interface PROPERTIES EXPORT_COMPILE_COMMANDS ON
										CXX_CLANG_TIDY "${PROGRAM_CLANG_TIDY}")

	add_library (Clang::clang-tidy-interface ALIAS clang-tidy-interface)
endif ()
