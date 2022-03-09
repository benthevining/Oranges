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

## USER INPUTS:
- CPACK_PACKAGE_EXECUTABLES
- CPACK_PROJECT_CONFIG_FILE
- CPACK_RESOURCE_FILE_WELCOME
- CPACK_PACKAGE_ICON
- CPACK_NSIS_MUI_FINISHPAGE_RUN
- CPACK_BUNDLE_PLIST
- CPACK_BUNDLE_STARTUP_COMMAND (program to run when user opens the bundle)

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

# CPACK_PACKAGE_INSTALL_DIRECTORY CPACK_PACKAGE_INSTALL_REGISTRY_KEY

#

include (OrangesSetDefaultCpackGenerator)

set (CPACK_STRIP_FILES TRUE)
set (CPACK_SOURCE_STRIP_FILES TRUE)

string (TOUPPER "${PROJECT_NAME}" UPPER_PROJECT_NAME)
string (TOLOWER "${PROJECT_NAME}" LOWER_PROJECT_NAME)

if(NOT APPLE AND NOT WIN32)
	set (CPACK_PACKAGE_NAME "${LOWER_PROJECT_NAME}" CACHE STRING "Name of the CPack package")
else()
	set (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "Name of the CPack package")
endif()

# set (CPACK_PACKAGE_VENDOR "${${UPPER_PROJECT_NAME}_VENDOR}" CACHE STRING "CPack package vendor")

set (CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}" CACHE STRING "CPack version major")
set (CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}" CACHE STRING "CPack version minor")
set (CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}" CACHE STRING "CPack version patch")

set (CPACK_PACKAGE_VERSION
	 "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

if(COMMON_PACKAGE_RELEASE)
	set (CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}-${COMMON_PACKAGE_RELEASE}")
endif()

set (CPACK_SOURCE_PACKAGE_FILE_NAME "${PROJECT_NAME}-${CPACK_PACKAGE_VERSION}"
	 CACHE STRING "CPack source package filename")

set (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${CPACK_PACKAGE_VERSION}"
	 CACHE STRING "Full CPack package filename, without extension")

# set (CPACK_PACKAGE_CONTACT "${${UPPER_PROJECT_NAME}_MAINTAINER}" CACHE STRING "CPack package
# maintainer contact")

set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${${PROJECT_NAME}_DESCRIPTION}"
	 CACHE STRING "CPack package description")

#

find_file (
	license_file
	NAMES LICENSE.txt LICENSE.md LICENSE COPYRIGHT.txt COPYRIGHT.md COPYRIGHT
	PATHS "${PROJECT_SOURCE_DIR}"
	DOC "Path to project license file"
	NO_DEFAULT_PATH)

if(license_file AND EXISTS "${license_file}")
	set (CPACK_RESOURCE_FILE_LICENSE "${license_file}" CACHE PATH
															 "License file for the CPack package")

elseif((NOT CPACK_RESOURCE_FILE_LICENSE) OR (NOT EXISTS "${CPACK_RESOURCE_FILE_LICENSE}"))
	message (
		AUTHOR_WARNING
			"License file not found, provide it or set CPACK_RESOURCE_FILE_LICENSE to point to an existing one."
		)
endif()

#

find_file (
	readme_file
	NAMES README README.txt README.md readme readme.txt readme.md
	PATHS "${PROJECT_SOURCE_DIR}"
	DOC "Path to project Readme/description file"
	NO_DEFAULT_PATH)

if(readme_file AND EXISTS "${readme_file}")

	set (CPACK_PACKAGE_DESCRIPTION_FILE "${readme_file}"
		 CACHE PATH "Description file for the CPack package")

	set (CPACK_RESOURCE_FILE_README "${readme_file}" CACHE PATH "Readme file for the CPack package")

elseif((NOT CPACK_PACKAGE_DESCRIPTION_FILE) OR (NOT EXISTS "${CPACK_PACKAGE_DESCRIPTION_FILE}"))
	message (
		AUTHOR_WARNING
			"Description file not found, provide it or set CPACK_PACKAGE_DESCRIPTION_FILE to point to an existing one."
		)
endif()

# #########################################################################################
# GENERATOR-SPECIFIC SETTINGS #####

set (CPACK_NSIS_MODIFY_PATH ON)

# set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\MyExecutable.exe") set(CPACK_NSIS_DISPLAY_NAME
# "${CPACK_PACKAGE_INSTALL_DIRECTORY} My Famous Project") set(CPACK_NSIS_HELP_LINK
# "http:\\\\\\\\www.my-project-home-page.org") set(CPACK_NSIS_URL_INFO_ABOUT
# "http:\\\\\\\\www.my-personal-home-page.com") set(CPACK_NSIS_CONTACT
# "me@my-personal-home-page.com")

# set (CPACK_NSIS_MUI_ICON "${CPACK_PACKAGE_ICON}" CACHE PATH "CPack installer icon")

# set (CPACK_NSIS_MUI_UNIICON "${CPACK_PACKAGE_ICON}" CACHE PATH "CPack uninstaller icon")

# set (CPACK_NSIS_INSTALLED_ICON_NAME "${CPACK_PACKAGE_ICON}" CACHE PATH "Icon for the Windows 'Add
# or Remove Programs' tool")

set (CPACK_NSIS_HELP_LINK "${${PROJECT_NAME}_HOMEPAGE_URL}"
	 CACHE STRING "Adds project help link to registry")

# set (CPACK_NSIS_CONTACT "${CPACK_PACKAGE_CONTACT}" CACHE STRING "Package contact email")

#

set (CPACK_OSX_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}")

set (CPACK_BUNDLE_NAME "${PROJECT_NAME}" CACHE STRING "Bundle name on MacOS")

# set (CPACK_BUNDLE_ICON "${CPACK_PACKAGE_ICON}" CACHE PATH "CPack bundle icon")

#

if(NOT (APPLE OR WIN32))
	include (LinuxLSBInfo)

	if(${LSB_CODENAME} MATCHES "bionic")
		set (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}" CACHE STRING
																		   "Deb package version")
	else()
		set (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}~${LSB_CODENAME}"
			 CACHE STRING "Deb package version")
	endif()
endif()

# CPACK_DEBIAN_BUILD_DEPENDS CPACK_DEBIAN_PACKAGE_CONFLICTS CPACK_DEBIAN_PACKAGE_REPLACES
# CPACK_DEBIAN_PACKAGE_RECOMMENDS CPACK_DEBIAN_PACKAGE_SUGGESTS

set (CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_LIST_DIR}/scripts/postinst;")

# set (CPACK_DEBIAN_PACKAGE_DEPENDS "${${UPPER_PROJECT_NAME}_PACKAGE_DEB_DEPENDS}" CACHE STRING "Deb
# package dependencies")

set (CPACK_DEBIAN_PACKAGE_HOMEPAGE "${${PROJECT_NAME}_HOMEPAGE_URL}"
	 CACHE STRING "Deb package homepage URL")
set (CPACK_DEBIAN_PACKAGE_SECTION devel CACHE STRING "Debian package category")

set (CPACK_DEBIAN_PACKAGE_PRIORITY optional CACHE STRING "Deb package priority")

#

set (CPACK_RPM_PACKAGE_GROUP "Development/Libraries" CACHE STRING "RPM package group")

# CPACK_RPM_PACKAGE_CONFLICTS CPACK_RPM_PACKAGE_OBSOLETES CPACK_RPM_PACKAGE_LICENSE

if(COMMON_PACKAGE_RELEASE)
	set (CPACK_RPM_PACKAGE_RELEASE "${COMMON_PACKAGE_RELEASE}" CACHE STRING "")
endif()

set (CPACK_RPM_PACKAGE_URL "${${PROJECT_NAME}_HOMEPAGE_URL}" CACHE STRING
																   "RPM package homepage URL")

set (CPACK_RPM_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}" CACHE STRING "RPM package version")

# set (CPACK_RPM_PACKAGE_REQUIRES "${${UPPER_PROJECT_NAME}_PACKAGE_RPM_DEPENDS}" CACHE STRING "RPM
# package dependencies")

set (CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_LIST_DIR}/scripts/rpmPostInstall.sh")

# #########################################################################################

set (config_file_output "${CMAKE_CURRENT_BINARY_DIR}/generated/CPackConfig.cmake")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/CPackConfig.cmake" "${config_file_output}" @ONLY)

set (CPACK_PROJECT_CONFIG_FILE "${config_file_output}")

if(PROJECT_IS_TOP_LEVEL)
	include (CPack)
endif()
