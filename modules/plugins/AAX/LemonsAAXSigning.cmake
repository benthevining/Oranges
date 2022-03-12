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

include (LemonsCmakeDevTools)

find_package (wraptool QUIET)

if(NOT TARGET PACE::wraptool)
	message (WARNING "wraptool cannot be found, AAX signing disabled!")
endif()

#

function(lemons_set_aax_signing_settings)

	set (oneValueArgs ACCOUNT SIGNID KEYFILE KEYPASSWORD)

	cmake_parse_arguments (LEMONS_AAX "FORCE" "${oneValueArgs}" "" ${ARGN})

	lemons_check_for_unparsed_args (LEMONS_AAX)
	lemons_check_for_unparsed_args (LEMONS_AAX)

	if(LEMONS_AAX_FORCE)
		set (aax_force FORCE)
	endif()

	macro(_lemons_aax_sign_config_check_for_option option description)
		if(LEMONS_AAX_${option})
			set (LEMONS_AAX_${option} "${LEMONS_AAX_${option}}" CACHE STRING "${description}"
																	  ${aax_force})
		endif()
	endmacro()

	_lemons_aax_sign_config_check_for_option (ACCOUNT "Account ID for AAX plugin signing")
	_lemons_aax_sign_config_check_for_option (SIGNID "SignID for AAX signing on Mac")
	_lemons_aax_sign_config_check_for_option (KEYFILE "Keyfile for AAX signing on Windows")
	_lemons_aax_sign_config_check_for_option (KEYPASSWORD "Keypassword for AAX signing on Windows")

endfunction()

#

function(lemons_configure_aax_plugin_signing)

	set (oneValueArgs TARGET GUID ACCOUNT SIGNID KEYFILE KEYPASSWORD)

	cmake_parse_arguments (LEMONS_AAX "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_AAX TARGET GUID ACCOUNT)
	lemons_check_for_unparsed_args (LEMONS_AAX)

	if(NOT TARGET PACE::wraptool)
		return ()
	endif()

	if(APPLE)
		lemons_require_function_arguments (LEMONS_AAX SIGNID)

		add_custom_command (
			TARGET ${LEMONS_AAX_TARGET}
			POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
			COMMAND
				PACE::wraptool ARGS sign --verbose --dsig1-compat off --account
				"${LEMONS_AAX_ACCOUNT}" --wcguid "${LEMONS_AAX_GUID}" --signid
				"${LEMONS_AAX_SIGNID}" --in
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>" --out
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>"
			COMMENT "Signing ${LEMONS_AAX_TARGET}...")
	elseif(WIN32)
		lemons_require_function_arguments (LEMONS_AAX KEYFILE KEYPASSWORD)

		add_custom_command (
			TARGET ${LEMONS_AAX_TARGET}
			POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
			COMMAND
				PACE::wraptool ARGS sign --verbose --dsig1-compat off --account
				"${LEMONS_AAX_ACCOUNT}" --keyfile "${LEMONS_AAX_KEYFILE}" --keypassword
				"${LEMONS_AAX_KEYPASSWORD}" --wcguid "${LEMONS_AAX_GUID}" --in
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>" --out
				"$<TARGET_PROPERTY:${aaxTarget},JUCE_PLUGIN_ARTEFACT_FILE>"
			COMMENT "Signing ${LEMONS_AAX_TARGET}...")
	endif()

	message (DEBUG "Configured AAX plugin signing!")
endfunction()
