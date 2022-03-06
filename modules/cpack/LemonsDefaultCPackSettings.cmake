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

## Include-time actions:
Sets up some default configuration settings for CPack.

## Includes:
- LemonsSetDefaultCpackGenerator

]]

include_guard (GLOBAL)

option (ORANGES_MARK_ALL_CPACK_OPTIONS_ADVANCED
		"Prevent CPack options from cluttering up the cache editor" ON)

include (LemonsSetDefaultCpackGenerator)

set (CPACK_STRIP_FILES TRUE)

if(NOT APPLE AND NOT WIN32)
	set (CPACK_PACKAGE_NAME "${LOWER_PROJECT_NAME}" CACHE STRING "Name of the CPack package")
else()
	set (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "Name of the CPack package")
endif()

set (CPACK_PACKAGE_VENDOR "${${UPPER_PROJECT_NAME}_VENDOR}" CACHE STRING "CPack package vendor")

set (CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}" CACHE STRING "CPack version major")
set (CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}" CACHE STRING "CPack version minor")
set (CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}" CACHE STRING "CPack version patch")

set (CPACK_PACKAGE_CONTACT "${${UPPER_PROJECT_NAME}_MAINTAINER}"
	 CACHE STRING "CPack package maintainer contact")

set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${${UPPER_PROJECT_NAME}_DESCRIPTION}"
	 CACHE STRING "CPack package description")

#

set (CPACK_PACKAGE_VERSION
	 "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

if(COMMON_PACKAGE_RELEASE)
	set (CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}-${COMMON_PACKAGE_RELEASE}")
endif()

#

set (license_file "${PROJECT_SOURCE_DIR}/LICENSE.txt")

if(NOT EXISTS "${license_file}")
	set (license_file "${PROJECT_SOURCE_DIR}/LICENSE.md")
endif()

if(NOT EXISTS "${license_file}")
	set (license_file "${PROJECT_SOURCE_DIR}/LICENSE")
endif()

if(EXISTS "${license_file}")
	set (CPACK_RESOURCE_FILE_LICENSE "${license_file}" CACHE PATH
															 "License file for the CPack package")
else()
	if((NOT CPACK_RESOURCE_FILE_LICENSE) OR (NOT EXISTS "${CPACK_RESOURCE_FILE_LICENSE}"))
		message (
			AUTHOR_WARNING
				"License file not found, provide it or set CPACK_RESOURCE_FILE_LICENSE to point to an existing one."
			)
	endif()
endif()

#

if(ORANGES_MARK_ALL_CPACK_OPTIONS_ADVANCED)
	mark_as_advanced (
		FORCE
		CPACK_PACKAGE_NAME
		CPACK_PACKAGE_VENDOR
		CPACK_PACKAGE_VERSION_MAJOR
		CPACK_PACKAGE_VERSION_MINOR
		CPACK_PACKAGE_VERSION_PATCH
		CPACK_PACKAGE_CONTACT
		CPACK_PACKAGE_DESCRIPTION_SUMMARY
		CPACK_RESOURCE_FILE_LICENSE)
endif()

#

if(CPACK_GENERATOR MATCHES "DEB")
	include ("${CMAKE_CURRENT_LIST_DIR}/scripts/deb/deb_settings.cmake")
elseif(CPACK_GENERATOR MATCHES "RPM")
	include ("${CMAKE_CURRENT_LIST_DIR}/scripts/rpm/rpm_settings.cmake")
endif()

#

if(PROJECT_IS_TOP_LEVEL)
	include (CPack)
endif()
