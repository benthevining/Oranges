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

This module provides the function oranges_fetch_repository.

Inclusion style: once globally

## Cache variables:
- ORANGES_FETCH_TRY_LOCAL_PACKAGES_FIRST : if ON, oranges_fetch_repository will first try find_package(<packageName>) before resorting to actually downloading the repository. Defaults to OFF.
- FETCHCONTENT_BASE_DIR : defines the directory where downloaded repositories will be stored.
I recommend setting this outside of the binary tree, so that the binary tree can be removed, and dependencies won't have to be redownloaded during the next cmake configure.
Defaults to ${CMAKE_SOURCE_DIR}/Cache.


## Functions:

### oranges_fetch_repository
```
oranges_fetch_repository (NAME <name>
						  [GIT_REPOSITORY <URL> | GITHUB_REPOSITORY <user/repository> | GITLAB_REPOSITORY <user/repository> | BITBUCKET_REPOSITORY <user/repository>]
						  [GIT_TAG <ref>]
						  [DOWNLOAD_ONLY] [FULL] [QUIET] [EXCLUDE_FROM_ALL] [NEVER_LOCAL]
						  [CMAKE_SUBDIR <rel_path>]
						  [CMAKE_OPTIONS "OPTION1 Value" "Option2 Value" ...]
						  [GIT_STRATEGY CHECKOUT|REBASE|REBASE_CHECKOUT]
						  [GIT_OPTIONS "Option1=Value" "Option2=Value" ...])
```

Fetches a git repository, with options for routing the call to `find_package()` or a local location.

Output variables (set in the scope of the caller):
- `<name>_SOURCE_DIR`
- `<name>_BINARY_DIR`

If the variable `FETCHCONTENT_SOURCE_DIR_<name>` is set, this function will simply call `add_subdirectory()` on that directory.

The variables `GITHUB_USERNAME`, `GITHUB_ACCESS_TOKEN`, `BITBUCKET_USERNAME`, and `BITBUCKET_PASSWORD` can be set to enable fetching private/protected repositories.

`GIT_TAG` can be an exact commit ref, or the name of a branch.

If `DOWNLOAD_ONLY` is present, `add_subdirectory()` will not be called on the fetched repository.

If `CMAKE_SUBDIR` is set, `add_subdirectory()` will be called on `<pkgName_SOURCE_DIR>/${CMAKE_SUBDIR}` (if a CMakeLists.txt exists in that directory).
This is useful for projects which have their CMakeLists.txt in a subdirectory, instead of in the root of their source tree.

If the `FULL` option is present, the full git history will be pulled (the default behavior is a shallow clone).

If the `QUIET` option is present, this function will not output status updates.

If the `EXCLUDE_FROM_ALL` option is present, it will be forwarded to the `add_subdirectory()` call for the fetched dependency (if `add_subdirectory()` is called).

If the `NEVER_LOCAL` option is present, then this function will never be routed to a `find_package()` call.

`CMAKE_OPTIONS` is an optional list of space-separated key-value pairs, which will be set as variables before calling `add_subdirectory()` on the fetched dependency (if `add_subdirectory()` is called).

`GIT_STRATEGY` may be one of `CHECKOUT`, `REBASE`, or `REBASE_CHECKOUT` and defines how the git repository is checked out and pulled.

`GIT_OPTIONS` is an optional list of "key=value" pairs that will be passed to the git pull's command line with --config.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

option (ORANGES_FETCH_TRY_LOCAL_PACKAGES_FIRST
		"Try local find_package before fetching dependencies from git" OFF)

include (LemonsCmakeDevTools)
include (OrangesSetUpCache)
include (FetchContent)

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
			message (VERBOSE " -- package ${ORANGES_ARG_NAME} found using find_package()")
			return ()
		endif()
	endif()

	if(ORANGES_ARG_GIT_REPOSITORY)
		set (git_repo_flag "${ORANGES_ARG_GIT_REPOSITORY}")
	elseif(ORANGES_ARG_GITHUB_REPOSITORY)
		if(GITHUB_USERNAME AND GITHUB_ACCESS_TOKEN)
			set (
				git_repo_flag
				"https://${GITHUB_USERNAME}:${GITHUB_ACCESS_TOKEN}@github.com/${ORANGES_ARG_GITHUB_REPOSITORY}.git"
				)
		else()
			set (git_repo_flag "https://git@github.com/${ORANGES_ARG_GITHUB_REPOSITORY}.git")
		endif()
	elseif(ORANGES_ARG_GITLAB_REPOSITORY)
		set (git_repo_flag "https://gitlab.com/${ORANGES_ARG_GITLAB_REPOSITORY}.git")
	elseif(ORANGES_ARG_BITBUCKET_REPOSITORY)
		if(BITBUCKET_USERNAME AND BITBUCKET_PASSWORD)
			set (
				git_repo_flag
				"https://${BITBUCKET_USERNAME}:${BITBUCKET_PASSWORD}@bitbucket.org/${ORANGES_ARG_BITBUCKET_REPOSITORY}.git"
				)
		else()
			set (git_repo_flag "https://bitbucket.org/${ORANGES_ARG_BITBUCKET_REPOSITORY}.git")
		endif()
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

		message (VERBOSE " -- package ${pkg_name} already populated")

		return ()
	endif()

	message (VERBOSE " -- populating package ${pkg_name} to ${pkg_source_dir}...")

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
		message (TRACE
				 " -- package ${pkg_name}: setting CMake option ${OPTION_KEY} to ${OPTION_VALUE}")
	endforeach()

	if(ORANGES_ARG_EXCLUDE_FROM_ALL)
		set (exclude_flag EXCLUDE_FROM_ALL)
	endif()

	message (VERBOSE " -- package ${pkg_name} - adding as subdirectory...")

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
