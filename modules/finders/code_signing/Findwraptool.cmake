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

Find module for PACE's wraptool code signing program.

Targets:
- PACE::wraptool : the wraptool executable.

Output variables:
- wraptool_FOUND

## Functions:

### wraptool_configure_aax_plugin_signing
```
wraptool_configure_aax_plugin_signing (TARGET <targetName>
									   GUID <guid>
									   [ACCOUNT <accountID>]
									   [SIGNID <signID>]
									   [KEYFILE <keyfilePath>]
									   [KEYPASSWORD <password>])
```

Configures signing of an AAX plugin target. Does nothing on Linux.

The `ACCOUNT`, `SIGNID`, `KEYFILE`, and `KEYPASSWORD` options set the cache variables `WRAPTOOL_ACCOUNT`, `WRAPTOOL_SIGNID`, `WRAPTOOL_KEYFILE`, and `WRAPTOOL_KEYPASSWORD`, respectively.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (wraptool PROPERTIES URL "https://paceap.com/pro-audio/"
						DESCRIPTION "AAX plugin signing tool provided by PACE")

set (wraptool_FOUND FALSE)

find_program (WRAPTOOL_PROGRAM wraptool)

mark_as_advanced (FORCE WRAPTOOL_PROGRAM)

if(WRAPTOOL_PROGRAM)
	add_executable (wraptool IMPORTED GLOBAL)

	set_target_properties (wraptool PROPERTIES IMPORTED_LOCATION "${WRAPTOOL_PROGRAM}")

	add_executable (PACE::wraptool ALIAS wraptool)

	set (wraptool_FOUND TRUE)
else()
	find_package_warning_or_error ("wraptool program cannot be found!")
endif()

#

function(wraptool_configure_aax_plugin_signing)

	set (oneValueArgs TARGET GUID ACCOUNT SIGNID KEYFILE KEYPASSWORD)

	cmake_parse_arguments (LEMONS_AAX "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_AAX TARGET GUID)
	lemons_check_for_unparsed_args (LEMONS_AAX)

	if(NOT TARGET PACE::wraptool)
		message (FATAL_ERROR "wraptool program not found, AAX signing cannot be configured!")
		return ()
	endif()

	if(NOT TARGET "${LEMONS_AAX_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${LEMONS_AAX_TARGET}!")
	endif()

	set (WRAPTOOL_ACCOUNT "${LEMONS_AAX_ACCOUNT}" CACHE STRING "Account ID")
	set (WRAPTOOL_SIGNID "${LEMONS_AAX_SIGNID}" CACHE STRING "Sign ID")
	set (WRAPTOOL_KEYFILE "${LEMONS_AAX_KEYFILE}" CACHE FILEPATH "Keyfile path")
	set (WRAPTOOL_KEYPASSWORD "${LEMONS_AAX_KEYPASSWORD}" CACHE STRING "Key password")

	if(APPLE)
		add_custom_command (
			TARGET "${LEMONS_AAX_TARGET}"
			POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
			COMMAND
				PACE::wraptool ARGS sign --verbose --dsig1-compat off --account
				"${WRAPTOOL_ACCOUNT}" --wcguid "${LEMONS_AAX_GUID}" --signid "${WRAPTOOL_SIGNID}"
				--in "$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>" --out
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>"
			COMMENT "Signing ${LEMONS_AAX_TARGET}...")

	elseif(WIN32)
		add_custom_command (
			TARGET "${LEMONS_AAX_TARGET}"
			POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
			COMMAND
				PACE::wraptool ARGS sign --verbose --dsig1-compat off --account
				"${WRAPTOOL_ACCOUNT}" --keyfile "${WRAPTOOL_KEYFILE}" --keypassword
				"${WRAPTOOL_KEYPASSWORD}" --wcguid "${LEMONS_AAX_GUID}" --in
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>" --out
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>"
			COMMENT "Signing ${LEMONS_AAX_TARGET}...")
	else()
		return ()
	endif()

	message (DEBUG "Configured AAX plugin signing!")

endfunction()
