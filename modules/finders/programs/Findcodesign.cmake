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

Find module for Apple's codesign program.

Targets:
- Apple::codesign : the codesign executable.

Output variables:
- codesign_FOUND

Functions:

codesign_sign_target (TARGET <target>)

Adds a post-build command to the specified target to run codesign on the target's bundle.


codesign_sign_plugin_targets (TARGET <pluginTarget>)

Configures code signing for every individual format target of a plugin.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (
	codesign PROPERTIES
	URL "https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Procedures/Procedures.html"
	DESCRIPTION "Apple's code signing tool")

set (codesign_FOUND FALSE)

find_program (CODESIGN_PROGRAM codesign)

mark_as_advanced (FORCE CODESIGN_PROGRAM)

if(CODESIGN_PROGRAM)
	add_executable (codesign IMPORTED GLOBAL)

	set_target_properties (codesign PROPERTIES IMPORTED_LOCATION "${CODESIGN_PROGRAM}")

	add_executable (Apple::codesign ALIAS codesign)

	set (codesign_FOUND TRUE)
else()
	if(codesign_FIND_REQUIRED)
		message (FATAL_ERROR "codesign program cannot be found!")
	endif()

	if(NOT codesign_FIND_QUIETLY)
		message (WARNING "codesign program cannot be found!")
	endif()
endif()

#

function(codesign_sign_target)

	cmake_parse_arguments (ORANGES_ARG "" "TARGET" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT TARGET Apple::codesign)
		message (FATAL_ERROR "Codesign cannot be found, plugin signing cannot be configured!")
		return ()
	endif()

	if(NOT TARGET "${ORANGES_ARG_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${ORANGES_ARG_TARGET}!")
	endif()

	set (dest "$<TARGET_BUNDLE_DIR:${ORANGES_ARG_TARGET}>")

	add_custom_command (
		TARGET "${ORANGES_ARG_TARGET}" POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
		COMMAND Apple::codesign -s - --force "${dest}" COMMENT "Signing ${ORANGES_ARG_TARGET}...")

	add_custom_command (
		TARGET "${ORANGES_ARG_TARGET}" POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
		COMMAND Apple::codesign -verify "${dest}"
		COMMENT "Verifying signing of ${ORANGES_ARG_TARGET}...")

endfunction()

#

function(codesign_sign_plugin_targets)

	cmake_parse_arguments (ORANGES_ARG "" "TARGET" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT TARGET "${ORANGES_ARG_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${ORANGES_ARG_TARGET}!")
	endif()

	get_target_property (plugin_formats "${ORANGES_ARG_TARGET}" JUCE_FORMATS)

	if(NOT plugin_formats)
		message (FATAL_ERROR "Error retrieving plugin formats from target ${ORANGES_ARG_TARGET}!")
	endif()

	foreach(format ${plugin_formats})

		set (targetName "${ORANGES_ARG_TARGET}_${format}")

		if(NOT TARGET "${targetName}")
			message (WARNING "Plugin format target ${targetName} does not exist!")
			continue ()
		endif()

		codesign_sign_target (TARGET "${targetName}")

	endforeach()

endfunction()
