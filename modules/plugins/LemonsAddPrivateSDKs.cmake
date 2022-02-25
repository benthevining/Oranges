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

include (LemonsGetCPM)

if(DEFINED ENV{LEMONS_PRIVATE_SDKS})
	file (REAL_PATH $ENV{LEMONS_PRIVATE_SDKS} CPM_PrivateSDKs_SOURCE EXPAND_TILDE)
endif()

cpmaddpackage (NAME PrivateSDKs GITHUB_REPOSITORY benthevining/PrivateSDKs GIT_TAG origin/main)

mark_as_advanced (LEMONS_AAX_SDK_PATH LEMONS_VST2_SDK_PATH)
