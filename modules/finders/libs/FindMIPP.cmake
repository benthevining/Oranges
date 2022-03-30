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

FindMipp
-------------------------

A find module for the MIPP library. This module fetches the JUCE sources from GitHub using oranges_fetch_repository().

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- MIPP_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- aff3ct::MIPP : MIPP library (INTERFACE)

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)
include (OrangesFetchRepository)

set_package_properties (MIPP PROPERTIES URL "https://github.com/aff3ct/MIPP"
						DESCRIPTION "Wrapper for various platform-specific SIMD instruction sets")

#

oranges_file_scoped_message_context ("FindMIPP")

set (MIPP_FOUND FALSE)

#

find_package_try_pkgconfig (aff3ct::MIPP mipp)

#

if(MIPP_FIND_QUIETLY)
	set (quiet_flag QUIET)
endif()

oranges_fetch_repository (
	NAME
	MIPP
	GITHUB_REPOSITORY
	aff3ct/MIPP
	GIT_TAG
	origin/master
	DOWNLOAD_ONLY
	NEVER_LOCAL
	${quiet_flag})

unset (quiet_flag)

add_library (MIPP INTERFACE)

target_include_directories (MIPP INTERFACE $<BUILD_INTERFACE:${MIPP_SOURCE_DIR}/src>
										   $<INSTALL_INTERFACE:include/MIPP>)

target_sources (MIPP INTERFACE $<BUILD_INTERFACE:${MIPP_SOURCE_DIR}/src/mipp.h>
							   $<INSTALL_INTERFACE:include/MIPP/mipp.h>)

oranges_export_alias_target (MIPP aff3ct)

oranges_install_targets (TARGETS MIPP EXPORT OrangesTargets COMPONENT_PREFIX aff3ct)

set (MIPP_FOUND TRUE)