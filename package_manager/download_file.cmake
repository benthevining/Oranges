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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

include ("${ORANGES_ROOT_DIR}/scripts/OrangesMacros.cmake")

include (OrangesDownloadFile)

#

if(NOT CACHE)
	set (CACHE "${CMAKE_CURRENT_LIST_DIR}/Cache")
endif()

set (FETCHCONTENT_BASE_DIR "${CACHE}" CACHE PATH "")

include (OrangesSetUpCache)

#

if(NOT URL)
	message (FATAL_ERROR "Argument URL is required!")
endif()

if(NOT FILENAME)
	message (FATAL_ERROR "Argument FILENAME is required!")
endif()

if(QUIET)
	set (quiet_flag QUIET)
endif()

if(TIMEOUT)
	set (timeout_flag TIMEOUT "${TIMEOUT}")
endif()

if(USERNAME)
	set (username_flag USERNAME "${USERNAME}")
endif()

if(PASSWORD)
	set (password_flag PASSWORD "${PASSWORD}")
endif()

if(EXPECTED_HASH)
	set (hash_flag EXPECTED_HASH "${EXPECTED_HASH}")
endif()

if(COPY_TO)
	set (copy_flag COPY_TO "${COPY_TO}")
endif()

oranges_download_file (
	URL
	"${URL}"
	FILENAME
	"${FILENAME}"
	${quiet_flag}
	${timeout_flag}
	${username_flag}
	${password_flag}
	${hash_flag}
	${copy_flag})
