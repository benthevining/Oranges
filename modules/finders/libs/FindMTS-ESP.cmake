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

FindMTS-ESP
-------------------------

A find module for the MTS-ESP MIDI tuning library.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- MTS-ESP_FOUND

Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Client
- Master
- All

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ODDSound::MTSClient : static library build of the MTS-ESP client library
- ODDSound::MTSMaster : static library build of the MTS-ESP master library
- ODDSound::MTS-ESP   : interface library that links to both the client and master libraries (or only one of them, if the other could not be created for some reason)

#]=======================================================================]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)
include (OrangesFetchRepository)

set_package_properties (
	MTS-ESP PROPERTIES URL "https://oddsound.com/index.php"
	DESCRIPTION "MIDI master/client microtuning tuning library")

#

oranges_file_scoped_message_context ("FindMTS-ESP")

set (MTS-ESP_FOUND FALSE)

#

find_package_try_pkgconfig (ODDSound::MTS-ESP)

#

if (MTS-ESP_FIND_QUIETLY)
	set (quiet_flag QUIET)
endif ()

oranges_fetch_repository (
	NAME MTS-ESP GITHUB_REPOSITORY ODDSound/MTS-ESP GIT_TAG origin/master
	DOWNLOAD_ONLY NEVER_LOCAL ${quiet_flag})

unset (quiet_flag)

find_package_default_component_list (Client Master)

# Client

if (NOT TARGET MTSClient)
	if (Client IN_LIST MTS-ESP_FIND_COMPONENTS)
		find_path (
			MTS_ESP_CLIENT_DIR libMTSClient.h
			PATHS "${MTS-ESP_SOURCE_DIR}/Client"
			DOC "MTS-ESP client sources directory" NO_DEFAULT_PATH)

		mark_as_advanced (FORCE MTS_ESP_CLIENT_DIR)

		if (MTS_ESP_CLIENT_DIR AND IS_DIRECTORY "${MTS_ESP_CLIENT_DIR}")

			find_package_message (
				MTS-ESP "MTS-ESP client lib - building from source"
				"MTS-ESP client - source")

			add_library (MTSClient STATIC)

			target_sources (
				MTSClient
				PRIVATE
					$<BUILD_INTERFACE:${MTS_ESP_CLIENT_DIR}/libMTSClient.cpp>
				PUBLIC
					$<BUILD_INTERFACE:${MTS_ESP_CLIENT_DIR}/libMTSClient.h>
					$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MTS-ESP/libMTSClient.h>
				)

			target_include_directories (
				MTSClient
				PRIVATE $<BUILD_INTERFACE:${MTS_ESP_CLIENT_DIR}>
						$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MTS-ESP>
				)

			install (TARGETS MTSClient EXPORT MTS_ESP_TARGETS)

			if (NOT TARGET ODDSound::MTSClient)
				add_library (ODDSound::MTSClient ALIAS MTSClient)
			endif ()
		else ()
			find_package_warning_or_error (
				"MTS-ESP component 'Client' could not be found!")
		endif ()
	endif ()
endif ()

# Master

if (NOT TARGET MTSMaster)
	if (Master IN_LIST MTS-ESP_FIND_COMPONENTS)
		find_path (
			MTS_ESP_MASTER_DIR libMTSMaster.h
			PATHS "${MTS-ESP_SOURCE_DIR}/Master"
			DOC "MTS-ESP master sources directory" NO_DEFAULT_PATH)

		mark_as_advanced (FORCE MTS_ESP_MASTER_DIR)

		if (MTS_ESP_MASTER_DIR AND IS_DIRECTORY "${MTS_ESP_MASTER_DIR}")

			# locate the libMTS dynamic library
			if (NOT TARGET lib_mts)
				if (WIN32)
					set (libMTS_name libMTS.dll)

					if (CMAKE_SIZEOF_VOID_P EQUAL 4) # 32-bit
						set (libMTS_paths
							 "Program Files (x86)\\Common Files\\MTS-ESP"
							 "${MTS-ESP_SOURCE_DIR}/libMTS/Win/32bit")
					elseif (CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
						set (libMTS_paths
							 "Program Files\\Common Files\\MTS-ESP"
							 "${MTS-ESP_SOURCE_DIR}/libMTS/Win/64bit")
					else ()
						message (
							FATAL_ERROR
								"Neither 32-bit nor 64-bit architecture could be detected!"
							)
					endif ()
				elseif (APPLE)
					set (libMTS_name libMTS.dylib)
					set (
						libMTS_paths
						"/Library/Application Support/MTS-ESP"
						"${MTS-ESP_SOURCE_DIR}/libMTS/Mac/i386_x86_64"
						"${MTS-ESP_SOURCE_DIR}/libMTS/Mac/x86_64_ARM")
				else () # Linux
					set (libMTS_name libMTS.so)
					set (libMTS_paths
						 "/usr/local/lib"
						 "${MTS-ESP_SOURCE_DIR}/libMTS/Linux/x86_64")
				endif ()

				find_library (
					libMTS NAMES "${libMTS_name}" PATHS "${libMTS_paths}"
					DOC "MTS-ESP master dynamic library")

				mark_as_advanced (FORCE libMTS)

				unset (libMTS_name)
				unset (libMTS_paths)

				if (libMTS)
					find_package_message (
						MTS-ESP "MTS-ESP master - found libMTS"
						"MTS-ESP master - ${libMTS}")

					add_library (lib_mts IMPORTED UNKNOWN)

					set_target_properties (lib_mts PROPERTIES IMPORTED_LOCATION
															  "${libMTS}")
				endif ()
			endif ()

			if (TARGET lib_mts)
				find_package_message (
					MTS-ESP "MTS-ESP master - building master lib from source"
					"MTS-ESP master - source")

				add_library (MTSMaster STATIC)

				target_link_libraries (MTSMaster PRIVATE lib_mts)

				target_sources (
					MTSMaster
					PRIVATE
						$<BUILD_INTERFACE:${MTS_ESP_MASTER_DIR}/libMTSMaster.cpp>
					PUBLIC
						$<BUILD_INTERFACE:${MTS_ESP_MASTER_DIR}/libMTSMaster.h>
						$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MTS-ESP/libMTSMaster.h>
					)

				target_include_directories (
					MTSMaster
					PRIVATE
						$<BUILD_INTERFACE:${MTS_ESP_MASTER_DIR}>
						$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MTS-ESP>
					)

				install (TARGETS MTSMaster EXPORT MTS_ESP_TARGETS)

				if (NOT TARGET ODDSound::MTSMaster)
					add_library (ODDSound::MTSMaster ALIAS MTSMaster)
				endif ()
			else ()
				find_package_warning_or_error ("libMTS could not be found!")
			endif ()
		endif ()

		if (NOT TARGET ODDSound::MTSMaster)
			find_package_warning_or_error (
				"MTS-ESP component 'Master' could not be found!")
		endif ()
	endif ()
endif ()

if (NOT (TARGET ODDSound::MTSClient OR TARGET ODDSound::MTSMaster))
	find_package_warning_or_error ("MTS-ESP could not be located!")
	return ()
endif ()

set (MTS-ESP_FOUND TRUE)

if (NOT TARGET MTS-ESP)
	add_library (MTS-ESP INTERFACE)
endif ()

target_link_libraries (
	MTS-ESP INTERFACE $<TARGET_NAME_IF_EXISTS:ODDSound::MTSClient>
					  $<TARGET_NAME_IF_EXISTS:ODDSound::MTSMaster>)

install (EXPORT MTS_ESP_TARGETS
		 DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/MTS-ESP" NAMESPACE ODDSound::
		 COMPONENT MTS-ESP)

include (CPackComponent)

cpack_add_component (MTS-ESP DISPLAY_NAME "MTS-ESP"
					 DESCRIPTION "MTS-ESP MIDI tuning library")

if (NOT TARGET ODDSound::MTS-ESP)
	add_library (ODDSound::MTS-ESP ALIAS MTS-ESP)
endif ()
