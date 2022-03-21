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

This module provides the function oranges_create_pkgconfig_file.

Inclusion style: once globally

## Functions:

### oranges_create_pkgconfig_file
```
oranges_create_pkgconfig_file (TARGET <targetName>
							   [OUTPUT_DIR <outputDir>]
							   [NAME <projectName>]
							   [INCLUDE_REL_PATH <basePath>]
							   [DESCRIPTION <projectDescription>]
							   [URL <projectURL>]
							   [VERSION <projectVersion>]
							   [NO_INSTALL]|[INSTALL_DEST <installDestination>]
							   [REQUIRES <requiredPackages...>])
```

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)
include (GNUInstallDirs)

set (pc_file_input "${CMAKE_CURRENT_LIST_DIR}/scripts/config.pc" CACHE INTERNAL "")

#

function(oranges_create_pkgconfig_file)

	set (options NO_INSTALL)
	set (
		oneValueArgs
		TARGET
		OUTPUT_DIR
		NAME
		INCLUDE_REL_PATH
		DESCRIPTION
		URL
		VERSION
		INSTALL_DEST)
	set (multiValueArgs REQUIRES)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)
	lemons_check_for_unparsed_args (ORANGES_ARG)
	oranges_assert_target_argument_is_target (ORANGES_ARG)

	if(ORANGES_ARG_NO_INSTALL AND ORANGES_ARG_INSTALL_DEST)
		message (
			"NO_INSTALL and INSTALL_DEST cannot both be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
			)
	endif()

	if(NOT ORANGES_ARG_OUTPUT_DIR)
		set (ORANGES_ARG_OUTPUT_DIR "${PROJECT_BINARY_DIR}/pkgconfig")
	endif()

	if(NOT ORANGES_ARG_NAME)
		set (ORANGES_ARG_NAME "${ORANGES_ARG_TARGET}")
	endif()

	if(NOT ORANGES_ARG_INCLUDE_REL_PATH)
		set (ORANGES_ARG_INCLUDE_REL_PATH "${ORANGES_ARG_NAME}")
	endif()

	if(NOT ORANGES_ARG_DESCRIPTION)
		set (ORANGES_ARG_DESCRIPTION "${PROJECT_DESCRIPTION}")
	endif()

	if(NOT ORANGES_ARG_URL)
		set (ORANGES_ARG_URL "${PROJECT_HOMEPAGE_URL}")
	endif()

	if(NOT ORANGES_ARG_VERSION)
		set (ORANGES_ARG_VERSION "${PROJECT_VERSION}")
	endif()

	if(NOT ORANGES_ARG_NO_INSTALL)
		set (ORANGES_ARG_NO_INSTALL FALSE)
	endif()

	if(NOT ORANGES_ARG_INSTALL_DEST)
		set (ORANGES_ARG_INSTALL_DEST "${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig")
	endif()

	list (JOIN ORANGES_ARG_REQUIRES " " ORANGES_ARG_REQUIRES)

	set (pc_file_configured "${ORANGES_ARG_OUTPUT_DIR}/${ORANGES_ARG_NAME}.pc.in")

	configure_file ("${pc_file_input}" "${pc_file_configured}" @ONLY)

	set (pc_file_output "${ORANGES_ARG_OUTPUT_DIR}/${ORANGES_ARG_NAME}-$<CONFIG>.pc")

	file (GENERATE OUTPUT "${pc_file_output}" INPUT "${pc_file_configured}"
		  TARGET "${ORANGES_ARG_TARGET}" NEWLINE_STYLE UNIX)

	if(NOT ORANGES_ARG_NO_INSTALL)
		install (FILES "${pc_file_output}" DESTINATION "${ORANGES_ARG_INSTALL_DEST}")
	endif()

endfunction()
