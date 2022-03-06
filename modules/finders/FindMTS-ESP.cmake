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

A find module for the MTS-ESP MIDI tuning library.

Components that may be specified:
- Client
- Master
- All

If no component(s) are specified, this module will default to creating both the client and master targets.

Targets:
- ODDSound::MTSClient : static library build of the MTS-ESP client library
- ODDSound::MTSMaster : static library build of the MTS-ESP master library
- ODDSound::MTS-ESP   : interface library that links to both the client and master libraries (or only one of them, if the other could not be created for some reason)

Output variables:
- MTS-ESP_FOUND
- MTS-ESP_DIR (points to the downloaded sources)

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsGetCPM)
include (LemonsCmakeDevTools)

CPMAddPackage (
	NAME
	MTS-ESP
	GITHUB_REPOSITORY
	ODDSound/MTS-ESP
	GIT_TAG
	origin/master
	DOWNLOAD_ONLY
	YES)

set (MTS-ESP_DIR "${MTS-ESP_SOURCE_DIR}")

# Client

# editorconfig-checker-disable
if((NOT MTS-ESP_FIND_COMPONENTS) OR (Client IN LISTS ${MTS-ESP_FIND_COMPONENTS})
   OR (All IN LISTS ${MTS-ESP_FIND_COMPONENTS}))
	# editorconfig-checker-enable

	find_path (MTS_ESP_CLIENT_DIR libMTSClient.h PATHS "${MTS-ESP_SOURCE_DIR}/Client"
			   DOC "MTS-ESP client sources directory")

	mark_as_advanced (FORCE MTS_ESP_CLIENT_DIR)

	if(MTS_ESP_CLIENT_DIR AND IS_DIRECTORY "${MTS_ESP_CLIENT_DIR}")

		add_library (MTS-ESP_Client STATIC)

		target_sources (
			MTS-ESP_Client
			PRIVATE $<BUILD_INTERFACE:${MTS_ESP_CLIENT_DIR}/libMTSClient.cpp>
					$<BUILD_INTERFACE:${MTS_ESP_CLIENT_DIR}/libMTSClient.h>
					$<INSTALL_INTERFACE:include/MTS-ESP_Client/libMTSClient.h>)

		target_include_directories (
			MTS-ESP_Client PUBLIC $<BUILD_INTERFACE:${MTS_ESP_CLIENT_DIR}>
								  $<INSTALL_INTERFACE:include/MTS-ESP_Client>)

		oranges_export_alias_target (MTS-ESP_Client ODDSound)

		oranges_install_targets (TARGETS MTS-ESP_Client EXPORT OrangesTargets)
	else()
		if(MTS-ESP_FIND_REQUIRED_Client)
			message (FATAL_ERROR "MTS-ESP component 'Client' could not be found!")
		endif()
	endif()
endif()

# Master

# editorconfig-checker-disable
if((NOT MTS-ESP_FIND_COMPONENTS) OR (Master IN LISTS ${MTS-ESP_FIND_COMPONENTS})
   OR (All IN LISTS ${MTS-ESP_FIND_COMPONENTS}))
	# editorconfig-checker-enable

	find_path (MTS_ESP_MASTER_DIR libMTSMaster.h PATHS "${MTS-ESP_SOURCE_DIR}/Master"
			   DOC "MTS-ESP master sources directory")

	mark_as_advanced (FORCE MTS_ESP_MASTER_DIR)

	if(MTS_ESP_MASTER_DIR AND IS_DIRECTORY "${MTS_ESP_MASTER_DIR}")

		# locate the libMTS dynamic library
		if(WIN32)
			if(CMAKE_SIZEOF_VOID_P EQUAL 4) # 32-bit
				find_library (
					libMTS NAMES LIBMTS.dll PATHS "Program Files (x86)\\Common Files\\MTS-ESP"
												  "${MTS-ESP_SOURCE_DIR}/libMTS/Win/32bit"
					DOC "MTS-ESP master dynamic library")
			elseif(CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
				find_library (
					libMTS NAMES LIBMTS.dll PATHS "Program Files\\Common Files\\MTS-ESP"
												  "${MTS-ESP_SOURCE_DIR}/libMTS/Win/64bit"
					DOC "MTS-ESP master dynamic library")
			else()
				if(NOT MTS-ESP_FIND_QUIETLY)
					message (WARNING "Neither 32-bit nor 64-bit architecture could be detected!")
				endif()
			endif()
		elseif(APPLE)
			find_library (
				libMTS
				NAMES libMTS.dylib
				PATHS "/Library/Application Support/MTS-ESP"
					  "${MTS-ESP_SOURCE_DIR}/libMTS/Mac/i386_x86_64"
					  "${MTS-ESP_SOURCE_DIR}/libMTS/Mac/x86_64_ARM"
				DOC "MTS-ESP master dynamic library")
		else() # Linux
			find_library (
				libMTS NAMES libMTS.so PATHS "/usr/local/lib"
											 "${MTS-ESP_SOURCE_DIR}/libMTS/Linux/x86_64"
				DOC "MTS-ESP master dynamic library")
		endif()

		mark_as_advanced (FORCE libMTS)

		if(libMTS)

			add_library (lib_mts IMPORTED UNKNOWN)

			set_target_properties (lib_mts PROPERTIES IMPORTED_LOCATION "${libMTS}")

			add_library (MTS-ESP_Master STATIC)

			target_link_libraries (MTS-ESP_Master PRIVATE lib_mts)

			target_sources (
				MTS-ESP_Master
				PRIVATE $<BUILD_INTERFACE:${MTS_ESP_MASTER_DIR}/libMTSMaster.cpp>
						$<BUILD_INTERFACE:${MTS_ESP_MASTER_DIR}/libMTSMaster.h>
						$<INSTALL_INTERFACE:include/MTS-ESP_Master/libMTSMaster.h>)

			target_include_directories (
				MTS-ESP_Master PUBLIC $<BUILD_INTERFACE:${MTS_ESP_MASTER_DIR}>
									  $<INSTALL_INTERFACE:include/MTS-ESP_Master>)

			oranges_export_alias_target (MTS-ESP_Master ODDSound)

			oranges_install_targets (TARGETS MTS-ESP_Master EXPORT OrangesTargets)

		else()
			if(NOT MTS-ESP_FIND_QUIETLY)
				message (WARNING "libMTS could not be found!")
			endif()
		endif()
	endif()

	if(NOT TARGET ODDSound::MTSMaster AND MTS-ESP_FIND_REQUIRED_Master)
		message (FATAL_ERROR "MTS-ESP component 'Master' could not be found!")
	endif()
endif()

if(TARGET ODDSound::MTSClient OR TARGET ODDSound::MTSMaster)

	set (MTS-ESP_FOUND TRUE)

	add_library (MTS-ESP INTERFACE)

	if(TARGET ODDSound::MTSClient)
		target_link_libraries (MTS-ESP INTERFACE ODDSound::MTSClient)
	endif()

	if(TARGET ODDSound::MTSMaster)
		target_link_libraries (MTS-ESP INTERFACE ODDSound::MTSMaster)
	endif()

	oranges_export_alias_target (MTS-ESP ODDSound)

	oranges_install_targets (TARGETS MTS-ESP EXPORT OrangesTargets OPTIONAL)

else()
	set (MTS-ESP_FOUND FALSE)

	if(MTS-ESP_FIND_REQUIRED)
		message (FATAL_ERROR "MTS-ESP could not be located!")
	endif()
endif()
