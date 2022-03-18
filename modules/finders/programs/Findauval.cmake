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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (
	auval PROPERTIES
	URL "https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/AudioUnitProgrammingGuide/AudioUnitDevelopmentFundamentals/AudioUnitDevelopmentFundamentals.html"
	DESCRIPTION "AudioUnit plugin validation tool")

set (auval_FOUND FALSE)

find_program (AUVAL_PROGRAM auval)

if(AUVAL_PROGRAM)
	add_executable (auval IMPORTED GLOBAL)

	set_target_properties (auval PROPERTIES IMPORTED_LOCATION "${AUVAL_PROGRAM}")

	add_executable (Apple::auval ALIAS auval)

	set (auval_FOUND TRUE)
else()
	if(auval_FIND_REQUIRED)
		message (FATAL_ERROR "auval cannot be found!")
	endif()

	if(NOT auval_FIND_QUIETLY)
		message (WARNING "auval cannot be found!")
	endif()
endif()

#

function(auval_add_plugin_test)

	if(NOT TARGET Apple::auval)
		message (WARNING "auval not found, cannot add tests!")
		return ()
	endif()

	set (oneValueArgs TARGET NAME REPEATS)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)

	if(NOT TARGET "${ORANGES_ARG_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${ORANGES_ARG_TARGET}!")
	endif()

	if(NOT ORANGES_ARG_NAME)
		set (ORANGES_ARG_NAME "${ORANGES_ARG_TARGET}.auval")
	endif()

	get_target_property (plugin_code "${ORANGES_ARG_TARGET}" JUCE_PLUGIN_CODE)

	if(NOT plugin_code)
		message (FATAL_ERROR "Error retrieving plugin code from target ${ORANGES_ARG_TARGET}!")
	endif()

	get_target_property (manufacturer_code "${ORANGES_ARG_TARGET}" JUCE_PLUGIN_MANUFACTURER_CODE)

	if(NOT manufacturer_code)
		message (
			FATAL_ERROR "Error retrieving manufacturer code from target ${ORANGES_ARG_TARGET}!")
	endif()

	# TO DO: CATEGORY!!
	get_target_property (category "${ORANGES_ARG_TARGET}" JUCE_AU_MAIN_TYPE)

	if(NOT category)
		message (FATAL_ERROR "Error retrieving category from target ${ORANGES_ARG_TARGET}!")
	endif()

	if(ORANGES_ARG_REPEATS)
		set (repeats_flag -r "${ORANGES_ARG_REPEATS}")
	endif()

	add_test (NAME "${ORANGES_ARG_NAME}" COMMAND Apple::auval -v "${category}" "${plugin_code}"
												 "${manufacturer_code}" ${repeats_flag})

	set_tests_properties ("${ORANGES_ARG_NAME}" PROPERTIES LABELS auval)

endfunction()
