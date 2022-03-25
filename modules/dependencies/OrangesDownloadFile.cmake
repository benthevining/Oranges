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

OrangesDownloadFile
-------------------------

This module provides the function :command:`oranges_download_file()`.

Download and cache a file at configure time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_download_file

	oranges_download_file ([URL <url> FILENAME <localFilename>] | [PACKAGE_NAME <name>] [GITHUB_REPOSITORY <username/repoName> REPO_REL_PATH <pathRelToRepoRoot>] [GIT_BRANCH <branchName>]
						   [PATH_OUTPUT <outputVar>]
						   [NO_CACHE] [QUIET] [NEVER_LOCAL]
						   [COPY_TO <path>]
						   [TIMEOUT <timeoutSeconds>]
						   [USERNAME <username>]
						   [PASSWORD <password>]
						   [EXPECTED_HASH <alg=expectedHash>])

If the `URL` argument is not given, then you must specify the GitHub repository, branch, and relative path to the file from the root of the repository.

`PATH_OUTPUT` may name a variable that will be set with the absolute path of the downloaded file, in the scope of the caller.
If `PATH_OUTPUT` isn't specified, the variable `${FILENAME}_PATH` will be set to the absolute path of the downloaded file in the scope of the caller.

If the variable `FILE_${FILENAME}_PATH` is set, this function will only set the path output variable to that path, not downloading anything.
However, if the `NEVER_LOCAL` option is present, the local filepath is ignored and the file will always be downloaded.

If the `QUIET` option is present, this function won't output status updates.

If the `NO_CACHE` option is present, the file will downloaded into the binary tree, instead of the cache folder.

If the `COPY_TO` argument is present, the downloaded file will be copied to the specified path once it has been fetched.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ORANGES_FILE_DOWNLOAD_CACHE : defines the directory where downloaded files will be stored.
I recommend setting this outside of the binary tree, so that the binary tree can be removed, and dependencies won't have to be redownloaded during the next cmake configure.
If FETCHCONTENT_BASE_DIR is set, this variable will default to the value of FETCHCONTENT_BASE_DIR.
Otherwise, this variable defaults to ${CMAKE_SOURCE_DIR}/Cache.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)
include (OrangesSetUpCache)

#

function(oranges_download_file)

	oranges_add_function_message_context ()

	macro(_oranges_copy_downloaded_file source_path dest_path)
		if(NOT "${${source_path}}" STREQUAL "${dest_path}")
			file (COPY_FILE "${${source_path}}" "${dest_path}")
		endif()
	endmacro()

	set (options NO_CACHE QUIET NEVER_LOCAL)
	set (
		oneValueArgs
		URL
		FILENAME
		GITHUB_REPOSITORY
		REPO_REL_PATH
		GIT_BRANCH
		PACKAGE_NAME
		TIMEOUT
		USERNAME
		PASSWORD
		EXPECTED_HASH
		PATH_OUTPUT
		COPY_TO)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG URL FILENAME)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(ORANGES_ARG_COPY_TO)
		cmake_language (DEFER CALL _oranges_copy_downloaded_file "${ORANGES_ARG_PATH_OUTPUT}"
						"${ORANGES_ARG_COPY_TO}")
	endif()

	if(NOT ORANGES_ARG_PATH_OUTPUT)
		set (ORANGES_ARG_PATH_OUTPUT "${FILENAME}_PATH")
	endif()

	if(FILE_${ORANGES_ARG_FILENAME}_PATH AND NOT ORANGES_ARG_NEVER_LOCAL)
		set (local_file_location "${FILE_${ORANGES_ARG_FILENAME}_PATH}")

		if(EXISTS "${local_file_location}")
			set (${ORANGES_ARG_PATH_OUTPUT} "${local_file_location}" PARENT_SCOPE)
			message (DEBUG
					 " -- file ${ORANGES_ARG_FILENAME} found locally at ${local_file_location}")
			return ()
		endif()
	endif()

	if(ORANGES_ARG_NO_CACHE)
		set (cached_file_location "${CMAKE_CURRENT_BINARY_DIR}/_deps/${ORANGES_ARG_FILENAME}")
	else()
		set (cached_file_location "${ORANGES_FILE_DOWNLOAD_CACHE}/${ORANGES_ARG_FILENAME}")
	endif()

	set (${ORANGES_ARG_PATH_OUTPUT} "${cached_file_location}" PARENT_SCOPE)

	if(EXISTS "${cached_file_location}")
		message (DEBUG " -- file ${ORANGES_ARG_FILENAME} found in cache at ${cached_file_location}")
		return ()
	endif()

	if(ORANGES_ARG_GITHUB_REPOSITORY OR ORANGES_ARG_REPO_REL_PATH)
		if((NOT ORANGES_ARG_GITHUB_REPOSITORY) OR (NOT ORANGES_ARG_REPO_REL_PATH))
			message (
				WARNING
					"${CMAKE_CURRENT_FUNCTION} - GITHUB_REPOSITORY and REPO_REL_PATH must both be specified!"
				)
		else()
			# check if this repository has been downloaded via OrangesFetchRepository... TO DO -
			# check branch...?

			if(ORANGES_ARG_PACKAGE_NAME)
				if(${ORANGES_ARG_PACKAGE_NAME}_SOURCE_DIR)
					set (git_repo_file_location
						 "${${ORANGES_ARG_PACKAGE_NAME}_SOURCE_DIR}/${ORANGES_ARG_REPO_REL_PATH}")

					if(EXISTS "${git_repo_file_location}")
						set (${ORANGES_ARG_PATH_OUTPUT} "${git_repo_file_location}" PARENT_SCOPE)
						message (
							DEBUG
							" -- file ${ORANGES_ARG_FILENAME} found in downloaded git repo ${ORANGES_ARG_PACKAGE_NAME} at ${git_repo_file_location}"
							)
						return ()
					endif()
				endif()
			endif()

			if(NOT ORANGES_ARG_GIT_BRANCH)
				set (ORANGES_ARG_GIT_BRANCH main)
			endif()

			set (
				ORANGES_ARG_URL
				"https://raw.githubusercontent.com/${ORANGES_ARG_GITHUB_REPOSITORY}/${ORANGES_ARG_GIT_BRANCH}/${ORANGES_ARG_REPO_REL_PATH}"
				)
		endif()
	else()
		if(ORANGES_ARG_USERNAME OR ORANGES_ARG_PASSWORD)
			if((NOT ORANGES_ARG_USERNAME) OR (NOT ORANGES_ARG_PASSWORD))
				message (
					FATAL_ERROR
						"${CMAKE_CURRENT_FUNCTION} - if specifying USERNAME or PASSWORD, both must be specified!"
					)
			endif()

			set (pwd_flag USERPWD "${ORANGES_ARG_USERNAME}:${ORANGES_ARG_PASSWORD}")
		endif()
	endif()

	oranges_forward_function_arguments (
		PREFIX
		ORANGES_ARG
		KIND
		oneVal
		ARGS
		TIMEOUT
		EXPECTED_HASH)

	if(NOT ORANGES_ARG_QUIET)
		set (progress_flag SHOW_PROGRESS)

		message (
			STATUS
				"Downloading file ${ORANGES_ARG_FILENAME} from ${ORANGES_ARG_URL} to ${cached_file_location}..."
			)
	endif()

	file (DOWNLOAD "${ORANGES_ARG_URL}" "${cached_file_location}" ${progress_flag} ${pwd_flag}
																  ${ORANGES_FORWARDED_ARGUMENTS})

endfunction()
