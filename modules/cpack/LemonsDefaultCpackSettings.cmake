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

#[[

## Include-time actions:
Sets up some default configuration settings for CPack.

## Includes:
- LemonsSetDefaultCpackGenerator

]]

include_guard (GLOBAL)

include (LemonsSetDefaultCpackGenerator)

set (CPACK_STRIP_FILES TRUE CACHE INTERNAL "")

if(NOT CPACK_PACKAGE_NAME)
	if(NOT APPLE AND NOT WIN32)
		set (CPACK_PACKAGE_NAME "${LOWER_PROJECT_NAME}" CACHE INTERNAL "")
	else()
		set (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE INTERNAL "")
	endif()
endif()

if(NOT CPACK_PACKAGE_VENDOR)
	set (CPACK_PACKAGE_VENDOR "${${UPPER_PROJECT_NAME}_VENDOR}" CACHE INTERNAL "")
endif()

set (CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR} CACHE INTERNAL "")
set (CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR} CACHE INTERNAL "")
set (CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH} CACHE INTERNAL "")

if(COMMON_PACKAGE_RELEASE)
	set (CPACK_PACKAGE_VERSION "${PROJECT_VERSION}-${COMMON_PACKAGE_RELEASE}" CACHE INTERNAL "")
else()
	set (CPACK_PACKAGE_VERSION ${PROJECT_VERSION} CACHE INTERNAL "")
endif()

if(NOT CPACK_PACKAGE_CONTACT)
	set (CPACK_PACKAGE_CONTACT "${${UPPER_PROJECT_NAME}_MAINTAINER}" CACHE INTERNAL "")
endif()

if(NOT CPACK_PACKAGE_DESCRIPTION_SUMMARY)
	set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${${UPPER_PROJECT_NAME}_DESCRIPTION}" CACHE INTERNAL "")
endif()

if(NOT CPACK_RESOURCE_FILE_LICENSE)
	set (CPACK_RESOURCE_FILE_LICENSE ${PROJECT_SOURCE_DIR}/LICENSE.txt CACHE INTERNAL "")
endif()

if(NOT EXISTS ${CPACK_RESOURCE_FILE_LICENSE})
	message (
		AUTHOR_WARNING
			"${CPACK_RESOURCE_FILE_LICENSE} file not found, provide it or set CPACK_RESOURCE_FILE_LICENSE to point to an existing one."
		)
endif()

if(CPACK_GENERATOR MATCHES "DEB")
	include ("${CMAKE_CURRENT_LIST_DIR}/scripts/deb/deb_settings.cmake")
elseif(CPACK_GENERATOR MATCHES "RPM")
	include ("${CMAKE_CURRENT_LIST_DIR}/scripts/rpm/rpm_settings.cmake")
endif()
