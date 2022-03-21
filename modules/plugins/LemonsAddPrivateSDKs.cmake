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

Fetches the PrivateSDKs repository.

Inclusion style: once globally

Options:
- FETCHCONTENT_SOURCE_DIR_PrivateSDKs
- GITHUB_USERNAME, GITHUB_ACCESS_TOKEN

Environment variables:
- LEMONS_PRIVATE_SDKS

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)

oranges_file_scoped_message_context ("LemonsAddPrivateSDKs")

include (OrangesFetchRepository)

if(DEFINED ENV{LEMONS_PRIVATE_SDKS})
	file (REAL_PATH "$ENV{LEMONS_PRIVATE_SDKS}" FETCHCONTENT_SOURCE_DIR_PrivateSDKs EXPAND_TILDE)
endif()

if(NOT FETCHCONTENT_SOURCE_DIR_PrivateSDKs)
	if(NOT (GITHUB_USERNAME AND GITHUB_ACCESS_TOKEN))
		message (WARNING "Github credentials missing!")
	endif()
endif()

oranges_fetch_repository (
	NAME
	PrivateSDKs
	GITHUB_REPOSITORY
	benthevining/PrivateSDKs
	GIT_TAG
	origin/main
	QUIET
	NEVER_LOCAL)

mark_as_advanced (FORCE LEMONS_AAX_SDK_PATH LEMONS_VST2_SDK_PATH)
