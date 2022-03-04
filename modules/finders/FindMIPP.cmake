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

A find module for the MIPP intrinsics library.

Targets:
- aff3ct::MIPP : interface library that can be linked against

Output variables:
- MIPP_FOUND
- MIPP_DIR

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsGetCPM)

CPMAddPackage (
	NAME
	MIPP
	GITHUB_REPOSITORY
	aff3ct/MIPP
	GIT_TAG
	origin/master
	DOWNLOAD_ONLY
	ON)

add_library (MIPP INTERFACE)

target_include_directories (MIPP INTERFACE "${MIPP_SOURCE_DIR}/src")

add_library (aff3ct::MIPP ALIAS MIPP)

set (MIPP_FOUND TRUE)
set (MIPP_DIR "${MIPP_SOURCE_DIR}")
