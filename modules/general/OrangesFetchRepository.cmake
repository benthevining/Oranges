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

set (FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/Cache"
	 CACHE PATH "Directory in which to cache all downloaded dependencies" FORCE)

set (ORANGES_FETCH_TRY_LOCAL_PACKAGES_FIRST OFF
	 CACHE BOOL "Try local find_package before fetching dependencies from git")

include (LemonsCmakeDevTools)
include (FetchContent)

#

#[[
oranges_fetch_repository (NAME <name>
						  GIT_REPOSITORY <URL> | GITHUB_REPOSITORY <user/repository> | GITLAB_REPOSITORY <> | BITBUCKET_REPOSITORY <>
						  [GIT_TAG <ref>]
						  [DOWNLOAD_ONLY] [FULL] [QUIET] [EXCLUDE_FROM_ALL] [NEVER_LOCAL]
						  [CMAKE_SUBDIR <rel_path>]
						  [CMAKE_OPTIONS "OPTION1 Value" "Option2 Value" ...]
						  [GIT_STRATEGY CHECKOUT|REBASE|REBASE_CHECKOUT]
						  [GIT_OPTIONS "Option1=Value" "Option2=Value" ...])

Output variables (set in the scope of the caller):
- <name>_SOURCE_DIR
- <name>_BINARY_DIR

variable FETCHCONTENT_SOURCE_DIR_<name> can override package location locally.

cache option ORANGES_FETCH_TRY_LOCAL_PACKAGES_FIRST will redirect this command to try using find_package first.

cache option ORANGES_FETCH_CACHE defines location of cached sources

]]

#

function(oranges_fetch_repository)

	set (options DOWNLOAD_ONLY FULL QUIET EXCLUDE_FROM_ALL NEVER_LOCAL)
	set (oneValueArgs NAME GIT_TAG GIT_REPOSITORY GITHUB_REPOSITORY CMAKE_SUBDIR GIT_STRATEGY)
	set (multiValueArgs CMAKE_OPTIONS GIT_OPTIONS)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG NAME)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(ORANGES_FETCH_TRY_LOCAL_PACKAGES_FIRST AND NOT ORANGES_ARG_NEVER_LOCAL)
		find_package ("${ORANGES_ARG_NAME}" QUIET)

		if(${ORANGES_ARG_NAME}_FOUND)
			set ("${ORANGES_ARG_NAME}_SOURCE_DIR" "${${ORANGES_ARG_NAME}_DIR}" PARENT_SCOPE)
			return ()
		endif()
	endif()

	if(ORANGES_ARG_GIT_REPOSITORY)
		set (git_repo_flag "${ORANGES_ARG_GIT_REPOSITORY}")
	elseif(ORANGES_ARG_GITHUB_REPOSITORY)
		set (git_repo_flag "https://github.com/${ORANGES_ARG_GITHUB_REPOSITORY}.git")
	elseif(ORANGES_ARG_GITLAB_REPOSITORY)
		set (git_repo_flag "https://gitlab.com/${ORANGES_ARG_GITLAB_REPOSITORY}.git")
	elseif(ORANGES_ARG_BITBUCKET_REPOSITORY)
		set (git_repo_flag "https://bitbucket.org/${ORANGES_ARG_BITBUCKET_REPOSITORY}.git")
	else()
		message (
			FATAL_ERROR
				"One of GIT_REPOSITORY, GITHUB_REPOSITORY, GITLAB_REPOSITORY, or BITBUCKET_REPOSITORY must be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
			)
	endif()

	if(ORANGES_ARG_CMAKE_SUBDIR)
		set (subdir_flag SOURCE_SUBDIR "${ORANGES_ARG_CMAKE_SUBDIR}")
	endif()

	if(NOT ORANGES_ARG_FULL)
		set (shallow_flag GIT_SHALLOW) # this will break if GIT_TAG is a specific commit
	endif()

	if(NOT ORANGES_ARG_QUIET)
		set (progress_flag GIT_PROGRESS)
	endif()

	if(ORANGES_ARG_GIT_OPTIONS)
		set (git_options GIT_CONFIG ${ORANGES_GIT_OPTIONS})
	endif()

	if(ORANGES_ARG_GIT_TAG)
		set (git_tag GIT_TAG "${ORANGES_ARG_GIT_TAG}")
	endif()

	if(ORANGES_ARG_GIT_STRATEGY)
		if(NOT ("${ORANGES_ARG_GIT_STRATEGY}" STREQUAL CHECKOUT OR "${ORANGES_ARG_GIT_STRATEGY}"
																   STREQUAL REBASE
				OR "${ORANGES_ARG_GIT_STRATEGY}" STREQUAL REBASE_CHECKOUT))
			message (
				WARNING
					"${CMAKE_CURRENT_FUNCTION} - GIT_STRATEGY must be CHECKOUT, REBASE, or REBASE_CHECKOUT"
				)
		else()
			set (git_strategy GIT_REMOTE_UPDATE_STRATEGY "${ORANGES_ARG_GIT_STRATEGY}")
		endif()
	endif()

	FetchContent_Declare (
		"${ORANGES_ARG_NAME}" GIT_REPOSITORY "${git_repo_flag}"
		${git_tag} ${shallow_flag} ${progress_flag} ${subdir_flag} ${git_options} ${git_strategy})

	_oranges_populate_repository ("${ORANGES_ARG_NAME}" "${ORANGES_ARG_DOWNLOAD_ONLY}"
								  "${ORANGES_ARG_CMAKE_OPTIONS}" "${ORANGES_ARG_CMAKE_SUBDIR}")

	set ("${ORANGES_ARG_NAME}_SOURCE_DIR" "${pkg_source_dir}" PARENT_SCOPE)
	set ("${ORANGES_ARG_NAME}_BINARY_DIR" "${pkg_bin_dir}" PARENT_SCOPE)
endfunction()

#

function(_oranges_populate_repository pkg_name download_only cmake_options cmake_subdir)

	FetchContent_GetProperties ("${pkg_name}" POPULATED fc_populated SOURCE_DIR pkg_source_dir
								BINARY_DIR pkg_bin_dir)

	if(fc_populated)
		set (pkg_source_dir "${pkg_source_dir}" PARENT_SCOPE)
		set (pkg_bin_dir "${pkg_bin_dir}" PARENT_SCOPE)

		return ()
	endif()

	FetchContent_Populate ("${pkg_name}")

	FetchContent_GetProperties ("${pkg_name}" SOURCE_DIR pkg_source_dir BINARY_DIR pkg_bin_dir)

	if(cmake_subdir)
		set (pkg_cmakelists "${pkg_source_dir}/${cmake_subdir}/CMakeLists.txt")
	else()
		set (pkg_cmakelists "${pkg_source_dir}/CMakeLists.txt")
	endif()

	if(download_only OR NOT EXISTS "${pkg_cmakelists}")
		set (pkg_source_dir "${pkg_source_dir}" PARENT_SCOPE)
		set (pkg_bin_dir "${pkg_bin_dir}" PARENT_SCOPE)

		return ()
	endif()

	foreach(option ${cmake_options})
		_oranges_parse_package_option ("${option}")
		set ("${OPTION_KEY}" "${OPTION_VALUE}")
	endforeach()

	if(ORANGES_ARG_EXCLUDE_FROM_ALL)
		set (exclude_flag EXCLUDE_FROM_ALL)
	endif()

	add_subdirectory ("${pkg_source_dir}" "${pkg_bin_dir}" ${exclude_flag})

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
