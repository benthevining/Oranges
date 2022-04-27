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

Findauval
-------------------------

Find the auval AudioUnit plugin testing tool.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- auval_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Apple::auval : the auval executable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	auval PROPERTIES
	URL "https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/AudioUnitProgrammingGuide/AudioUnitDevelopmentFundamentals/AudioUnitDevelopmentFundamentals.html"
	DESCRIPTION "AudioUnit plugin validation tool")

#

oranges_file_scoped_message_context ("Findauval")

#

if (TARGET Apple::auval)
	set (auval_FOUND TRUE)
	return ()
endif ()

set (auval_FOUND FALSE)

find_program (AUVAL_PROGRAM auval DOC "auval executable")

if (AUVAL_PROGRAM)
	add_executable (auval IMPORTED GLOBAL)

	set_target_properties (auval PROPERTIES IMPORTED_LOCATION
											"${AUVAL_PROGRAM}")

	add_executable (Apple::auval ALIAS auval)

	set (auval_FOUND TRUE)
else ()
	find_package_warning_or_error ("auval cannot be found!")
endif ()
