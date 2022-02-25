# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsAAXSigning)
include (LemonsCmakeDevTools)

function(lemons_configure_plugin_signing)

	set (oneValueArgs TARGET GUID ACCOUNT SIGNID KEYFILE KEYPASSWORD)

	cmake_parse_arguments (LEMONS_SIGN "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_SIGN TARGET)
	lemons_check_for_unparsed_args (LEMONS_SIGN)

	set (aaxTarget "${LEMONS_SIGN_TARGET}_AAX")

	if(TARGET ${aaxTarget} AND LEMONS_SIGN_GUID AND LEMONS_SIGN_ACCOUNT)
		lemons_configure_aax_plugin_signing (
			TARGET
			${aaxTarget}
			GUID
			${LEMONS_SIGN_GUID}
			ACCOUNT
			${LEMONS_SIGN_ACCOUNT}
			SIGNID
			${LEMONS_SIGN_SIGNID}
			KEYFILE
			${LEMONS_SIGN_KEYFILE}
			KEYPASSWORD
			${LEMONS_SIGN_KEYPASSWORD})
	endif()

	get_target_property (pluginFormats ${LEMONS_SIGN_TARGET} JUCE_FORMATS)

	if(NOT pluginFormats)
		message (AUTHOR_WARNING "Error retrieving plugin formats of target ${LEMONS_SIGN_TARGET}!")
		return ()
	endif()

	function(_lemons_config_plugin_format_signing formatTarget)

		message (DEBUG "Configuring signing for plugin target ${formatTarget}...")

		if(APPLE)

			find_program (CODESIGN codesign)

			if(NOT CODESIGN)
				message (WARNING "Codesign cannot be found, plugin signing cannot be configured!")
				return ()
			endif()

			add_custom_command (
				TARGET ${formatTarget} POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
				COMMAND ${CODESIGN} -s - --force "$<TARGET_BUNDLE_DIR:${formatTarget}>"
				COMMENT "Signing ${formatTarget}...")

			add_custom_command (
				TARGET ${formatTarget} POST_BUILD VERBATIM COMMAND_EXPAND_LISTS
				COMMAND ${CODESIGN} -verify "$<TARGET_BUNDLE_DIR:${formatTarget}>"
				COMMENT "Verifying signing of ${formatTarget}...")

		elseif(WIN32)

		else()

		endif()
	endfunction()

	foreach(pluginFormat ${pluginFormats})

		set (formatTarget "${LEMONS_SIGN_TARGET}_${pluginFormat}")

		if(NOT TARGET ${formatTarget})
			message (
				AUTHOR_WARNING
					"Format ${pluginFormat} is in property list for target ${LEMONS_SIGN_TARGET}, but target ${formatTarget} does not exist!"
				)
			continue ()
		endif()

		_lemons_config_plugin_format_signing (${formatTarget})

	endforeach()

endfunction()
