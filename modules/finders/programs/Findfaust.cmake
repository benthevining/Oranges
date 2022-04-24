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

Findfaust
-------------------------

Find the Faust compiler.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- faust_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- faust::faust : The Faust compiler executable

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (faust PROPERTIES URL "https://faust.grame.fr/"
						DESCRIPTION "Compiler for Faust .dsp files into c++ source code")

oranges_file_scoped_message_context ("Findfaust")

set (faust_FOUND FALSE)

find_program (PROGRAM_FAUST faust DOC "Faust compiler")

mark_as_advanced (FORCE PROGRAM_FAUST)

if(PROGRAM_FAUST)
	add_executable (faust IMPORTED GLOBAL)

	set_target_properties (faust PROPERTIES IMPORTED_LOCATION "${PROGRAM_FAUST}")

	add_executable (faust::faust ALIAS faust)

	set (faust_FOUND TRUE)
else()
	find_package_warning_or_error ("faust compiler cannot be found!")
endif()
