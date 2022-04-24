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

Findcodesign
-------------------------

Find Apple's codesign program.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- codesign_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Apple::codesign : the codesign executable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)
include (CallForEachPluginFormat)

set_package_properties (
	codesign PROPERTIES
	URL "https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Procedures/Procedures.html"
	DESCRIPTION "Apple's code signing tool")

oranges_file_scoped_message_context ("Findcodesign")

if(TARGET Apple::codesign)
	set (codesign_FOUND TRUE)
	return ()
endif()

set (codesign_FOUND FALSE)

find_program (CODESIGN_PROGRAM codesign DOC "Apple's codesign program")

mark_as_advanced (FORCE CODESIGN_PROGRAM)

if(CODESIGN_PROGRAM)
	add_executable (codesign IMPORTED GLOBAL)

	set_target_properties (codesign PROPERTIES IMPORTED_LOCATION "${CODESIGN_PROGRAM}")

	add_executable (Apple::codesign ALIAS codesign)

	set (codesign_FOUND TRUE)
else()
	find_package_warning_or_error ("codesign program cannot be found!")
endif()
