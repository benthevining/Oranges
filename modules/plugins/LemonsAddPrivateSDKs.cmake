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

include (OrangesFetchRepository)

if(DEFINED ENV{LEMONS_PRIVATE_SDKS})
	file (REAL_PATH "$ENV{LEMONS_PRIVATE_SDKS}" FETCHCONTENT_SOURCE_DIR_PrivateSDKs EXPAND_TILDE)
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

mark_as_advanced (LEMONS_AAX_SDK_PATH LEMONS_VST2_SDK_PATH)
