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

if(FETCHCONTENT_BASE_DIR)
	set (ORANGES_FILE_DOWNLOAD_CACHE "${FETCHCONTENT_BASE_DIR}"
		 CACHE PATH "Directory in which to cache all downloaded files")
else()
	set (ORANGES_FILE_DOWNLOAD_CACHE "${CMAKE_SOURCE_DIR}/Cache"
		 CACHE PATH "Directory in which to cache all downloaded files")
endif()

mark_as_advanced (FORCE ORANGES_FILE_DOWNLOAD_CACHE)

#

function(oranges_download_file)

	set (options NO_CACHE QUIET)
	set (
		oneValueArgs
		URL
		FILENAME
		TIMEOUT
		USERNAME
		PASSWORD
		EXPECTED_HASH
		PATH_OUTPUT)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG URL FILENAME)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_PATH_OUTPUT)
		set (ORANGES_ARG_PATH_OUTPUT "${FILENAME}_PATH")
	endif()

	if(ORANGES_ARG_NO_CACHE)
		set (cached_file_location "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_FILENAME}")
	else()
		if(FILE_${ORANGES_ARG_FILENAME}_PATH)
			set (cached_file_location "${FILE_${ORANGES_ARG_FILENAME}_PATH}")
		else()
			set (cached_file_location "${ORANGES_FILE_DOWNLOAD_CACHE}/${ORANGES_ARG_FILENAME}")
		endif()
	endif()

	set (${ORANGES_ARG_PATH_OUTPUT} "${cached_file_location}" PARENT_SCOPE)

	if(EXISTS "${cached_file_location}")
		return ()
	endif()

	if(NOT ORANGES_ARG_QUIET)
		set (progress_flag SHOW_PROGRESS)

		message (
			STATUS
				"Downloading file ${ORANGES_ARG_FILENAME} from ${ORANGES_ARG_URL} to ${cached_file_location}..."
			)
	endif()

	if(ORANGES_ARG_TIMEOUT)
		set (timeout_flag TIMEOUT "${ORANGES_ARG_TIMEOUT}")
	endif()

	if(ORANGES_ARG_USERNAME OR ORANGES_ARG_PASSWORD)
		if((NOT ORANGES_ARG_USERNAME) OR (NOT ORANGES_ARG_PASSWORD))
			message (
				FATAL_ERROR
					"${CMAKE_CURRENT_FUNCTION} - if specifying USERNAME or PASSWORD, both must be specified!"
				)
		endif()

		set (pwd_flag USERPWD "${ORANGES_ARG_USERNAME}:${ORANGES_ARG_PASSWORD}")
	endif()

	if(ORANGES_ARG_EXPECTED_HASH)
		set (hash_flag EXPECTED_HASH "${ORANGES_ARG_EXPECTED_HASH}")
	endif()

	file (DOWNLOAD "${ORANGES_ARG_URL}" "${cached_file_location}" ${progress_flag} ${timeout_flag}
																  ${pwd_flag} ${hash_flag})

endfunction()
