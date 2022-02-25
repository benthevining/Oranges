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

include (LemonsCmakeDevTools)
include (LemonsAAXSigning)
include (LemonsInstallDeps)
include (LemonsRunClean)

function(lemons_parse_project_configuration_file)

	cmake_parse_arguments (LEMONS_CONFIG "FORCE" "FILE" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_CONFIG FILE)

	file (READ "${LEMONS_CONFIG_FILE}" configFileContents)

	string (STRIP "${configFileContents}" configFileContents)

	string (JSON jsonProjName GET ${configFileContents} "project" "name")

	if(NOT "${jsonProjName}" STREQUAL "${PROJECT_NAME}")
		message (
			AUTHOR_WARNING
				"The current CMake project name ('${PROJECT_NAME}') doesn't match the configuration file ('${jsonProjName}')."
			)
	endif()

	string (
		JSON
		jsonAppleDevID
		ERROR_VARIABLE
		errno
		GET
		${configFileContents}
		"project"
		"AppleDevelopmentTeamId")

	if(LEMONS_CONFIG_FORCE)
		set (${PROJECT_NAME}_CONFIG_FILE "${LEMONS_CONFIG_FILE}"
			 CACHE PATH "Path to the configuration file for this project" FORCE)

		if(jsonAppleDevID)
			set (CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${jsonAppleDevID}"
				 CACHE STRING "10-character ID for your Apple developer account" FORCE)
		endif()
	else()
		set (${PROJECT_NAME}_CONFIG_FILE "${LEMONS_CONFIG_FILE}"
			 CACHE PATH "Path to the configuration file for this project")

		if(jsonAppleDevID)
			set (CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${jsonAppleDevID}"
				 CACHE STRING "10-character ID for your Apple developer account")
		endif()
	endif()

	mark_as_advanced (${PROJECT_NAME}_CONFIG_FILE CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM)

	string (
		JSON
		aaxSignJsonObj
		ERROR_VARIABLE
		errno
		GET
		${configFileContents}
		"AAX_signing")

	if(aaxSignJsonObj)
		set (aaxSettings "")

		string (
			JSON
			accountJson
			ERROR_VARIABLE
			errno
			GET
			${aaxSignJsonObj}
			"Account")
		if(accountJson)
			list (APPEND aaxSettings ACCOUNT "${accountJson}")
		endif()

		string (
			JSON
			signIDJson
			ERROR_VARIABLE
			errno
			GET
			${aaxSignJsonObj}
			"SignID")
		if(signIDJson)
			list (APPEND aaxSettings SIGNID "${signIDJson}")
		endif()

		string (
			JSON
			keyfileJson
			ERROR_VARIABLE
			errno
			GET
			${aaxSignJsonObj}
			"Keyfile")
		if(keyfileJson)
			list (APPEND aaxSettings KEYFILE "${keyfileJson}")
		endif()

		string (
			JSON
			keypasswordJson
			ERROR_VARIABLE
			errno
			GET
			${aaxSignJsonObj}
			"Keypassword")
		if(keypasswordJson)
			list (APPEND keypasswordJson KEYPASSWORD "${keypasswordJson}")
		endif()

		if(aaxSettings)
			if(LEMONS_CONFIG_FORCE)
				list (APPEND aaxSettings FORCE)
			endif()

			lemons_set_aax_signing_settings (${aaxSettings})
		endif()
	endif()

	set_property (DIRECTORY "${PROJECT_SOURCE_DIR}" APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
																	"${LEMONS_CONFIG_FILE}")

endfunction()
