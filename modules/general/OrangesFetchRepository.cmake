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
include (FetchContent)

#

function(oranges_fetch_repository)

	set (options DOWNLOAD_ONLY FULL QUIET EXCLUDE_FROM_ALL)
	set (oneValueArgs NAME GIT_TAG GIT_REPOSITORY GITHUB_REPOSITORY CMAKE_SUBDIR)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "OPTIONS" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG NAME GIT_TAG)

	if(NOT ORANGES_ARG_GIT_REPOSITORY AND NOT ORANGES_ARG_GITHUB_REPOSITORY)
		message (
			FATAL_ERROR
				"One of GIT_REPOSITORY or GITHUB_REPOSITORY must be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
			)
	endif()

	if(ORANGES_ARG_DOWNLOAD_ONLY AND ORANGES_ARG_CMAKE_SUBDIR)
		message (
			AUTHOR_WARNING
				"DOWNLOAD_ONLY and CMAKE_SUBDIR cannot both be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
			)
	endif()

	if(ORANGES_ARG_CMAKE_SUBDIR)
		set (subdir_flag SOURCE_SUBDIR "${ORANGES_ARG_CMAKE_SUBDIR}")
	endif()

	if(ORANGES_ARG_GIT_REPOSITORY)
		set (git_repo_flag "${ORANGES_ARG_GIT_REPOSITORY}")
	else()
		set (git_repo_flag "www.github.com/${ORANGES_ARG_GITHUB_REPOSITORY}.git")
	endif()

	if(NOT ORANGES_ARG_FULL)
		set (shallow_flag GIT_SHALLOW)
	endif()

	if(NOT ORANGES_ARG_QUIET)
		set (progress_flag GIT_PROGRESS)
	endif()

	FetchContent_Declare (
		"${ORANGES_ARG_NAME}" GIT_REPOSITORY "${git_repo_flag}" GIT_TAG "${ORANGES_ARG_GIT_TAG}"
		${shallow_flag} ${progress_flag} ${subdir_flag})

	FetchContent_GetProperties ("${ORANGES_ARG_NAME}")

	if(NOT ${${ORANGES_ARG_NAME}_POPULATED})
		FetchContent_Populate ("${ORANGES_ARG_NAME}")

		if(NOT ORANGES_ARG_DOWNLOAD_ONLY AND EXISTS "${depname_SOURCE_DIR}/CMakeLists.txt")
			if(ORANGES_ARG_EXCLUDE_FROM_ALL)
				set (exclude_flag EXCLUDE_FROM_ALL)
			endif()

			foreach(option ORANGES_ARG_OPTIONS)
				_oranges_parse_package_option ("${option}")
				set ("${OPTION_KEY}" "${OPTION_VALUE}")
			endforeach()

			add_subdirectory ("${depname_SOURCE_DIR}" "${depname_BINARY_DIR}" ${exclude_flag})
		endif()
	endif()

	set ("${ORANGES_ARG_NAME}_SOURCE_DIR" "${depname_SOURCE_DIR}" PARENT_SCOPE)

	if(ORANGES_ARG_DOWNLOAD_ONLY)
		set ("${ORANGES_ARG_NAME}_BINARY_DIR" "" PARENT_SCOPE)
	else()
		set ("${ORANGES_ARG_NAME}_BINARY_DIR" "${depname_BINARY_DIR}" PARENT_SCOPE)
	endif()
endfunction()

#

function(_oranges_parse_package_option OPTION)
	string (REGEX MATCH "^[^ ]+" OPTION_KEY "${OPTION}")
	string (LENGTH "${OPTION}" OPTION_LENGTH)
	string (LENGTH "${OPTION_KEY}" OPTION_KEY_LENGTH)

	if(OPTION_KEY_LENGTH STREQUAL OPTION_LENGTH)
		# no value for key provided, assume user wants to set option to "ON"
		set (OPTION_VALUE "ON")
	else()
		math (EXPR OPTION_KEY_LENGTH "${OPTION_KEY_LENGTH}+1")
		string (SUBSTRING "${OPTION}" "${OPTION_KEY_LENGTH}" "-1" OPTION_VALUE)
	endif()

	set (OPTION_KEY "${OPTION_KEY}" PARENT_SCOPE)
	set (OPTION_VALUE "${OPTION_VALUE}" PARENT_SCOPE)
endfunction()
