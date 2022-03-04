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
- ODDSound::MTS_ESP   : interface library that links to both the client and master libraries (or only one of them, if the other could not be created for some reason)

Output variables:
- MTS-ESP_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

set (MTS_ESP_ROOT_DIR "")

# Client

# editorconfig-checker-disable
if((NOT MTS-ESP_FIND_COMPONENTS) OR (Client IN LISTS ${MTS-ESP_FIND_COMPONENTS})
   OR (All IN LISTS ${MTS-ESP_FIND_COMPONENTS}))
	# editorconfig-checker-enable

	find_path (MTS_ESP_CLIENT_DIR libMTSClient.h PATHS "${MTS_ESP_ROOT_DIR}/Client"
			   DOC "MTS-ESP client sources directory")

	if(MTS_ESP_CLIENT_DIR AND IS_DIRECTORY "${MTS_ESP_CLIENT_DIR}")

		add_library (MTS-ESP_Client STATIC)

		target_sources (MTS-ESP_Client PRIVATE "${MTS_ESP_CLIENT_DIR}/libMTSClient.cpp"
											   "${MTS_ESP_CLIENT_DIR}/libMTSClient.h")

		target_include_directories (MTS-ESP_Client PUBLIC "${MTS_ESP_CLIENT_DIR}")

		add_library (ODDSound::MTSClient ALIAS MTS-ESP_Client)
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

	find_path (MTS_ESP_MASTER_DIR libMTSMaster.h PATHS "${MTS_ESP_ROOT_DIR}/Master"
			   DOC "MTS-ESP master sources directory")

	if(MTS_ESP_MASTER_DIR AND IS_DIRECTORY "${MTS_ESP_MASTER_DIR}")

		# locate the libMTS dynamic library
		if(WIN32)
			if(CMAKE_SIZEOF_VOID_P EQUAL 4) # 32-bit
				find_library (
					libMTS NAMES LIBMTS.dll PATHS "Program Files (x86)\\Common Files\\MTS-ESP"
												  "${MTS_ESP_ROOT_DIR}/libMTS/Win/32bit"
					DOC "MTS-ESP master dynamic library")
			elseif(CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
				find_library (
					libMTS NAMES LIBMTS.dll PATHS "Program Files\\Common Files\\MTS-ESP"
												  "${MTS_ESP_ROOT_DIR}/libMTS/Win/64bit"
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
					  "${MTS_ESP_ROOT_DIR}/libMTS/Mac/i386_x86_64"
					  "${MTS_ESP_ROOT_DIR}/libMTS/Mac/x86_64_ARM"
				DOC "MTS-ESP master dynamic library")
		else() # Linux
			find_library (
				libMTS NAMES libMTS.so PATHS "/usr/local/lib"
											 "${MTS_ESP_ROOT_DIR}/libMTS/Linux/x86_64"
				DOC "MTS-ESP master dynamic library")
		endif()

		if(libMTS)

			add_library (MTS-ESP_Master STATIC)

			target_link_libraries (MTS-ESP_Master PRIVATE "${libMTS}")

			target_sources (MTS-ESP_Master PRIVATE "${MTS_ESP_MASTER_DIR}/libMTSMaster.cpp"
												   "${MTS_ESP_MASTER_DIR}/libMTSMaster.h")

			target_include_directories (MTS-ESP_Client PUBLIC "${MTS_ESP_MASTER_DIR}")

			add_library (ODDSound::MTSMaster ALIAS MTS-ESP_Master)

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

	add_library (ODDSound::MTS_ESP INTERFACE)

	if(TARGET ODDSound::MTSClient)
		target_link_libraries (ODDSound::MTS_ESP INTERFACE ODDSound::MTSClient)
	endif()

	if(TARGET ODDSound::MTSMaster)
		target_link_libraries (ODDSound::MTS_ESP INTERFACE ODDSound::MTSMaster)
	endif()
else()
	set (MTS-ESP_FOUND FALSE)

	if(MTS-ESP_FIND_REQUIRED)
		message (FATAL_ERROR "MTS-ESP could not be located!")
	endif()
endif()
