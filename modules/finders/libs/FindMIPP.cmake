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

set_package_properties (
    MIPP PROPERTIES URL "https://github.com/aff3ct/MIPP"
    DESCRIPTION "Wrapper for various platform-specific SIMD instruction sets")

#

if (TARGET aff3ct::MIPP)
    set (MIPP_FOUND TRUE)
    return ()
endif ()

oranges_file_scoped_message_context ("FindMIPP")

set (MIPP_FOUND FALSE)

#

if (MIPP_FIND_QUIETLY)
    set (quiet_flag QUIET)
endif ()

oranges_fetch_repository (
    NAME MIPP GITHUB_REPOSITORY aff3ct/MIPP GIT_TAG origin/master
    DOWNLOAD_ONLY NEVER_LOCAL ${quiet_flag})

unset (quiet_flag)

add_library (MIPP INTERFACE)

target_include_directories (
    MIPP INTERFACE $<BUILD_INTERFACE:${MIPP_SOURCE_DIR}/src>
                   $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MIPP>)

target_sources (
    MIPP INTERFACE $<BUILD_INTERFACE:${MIPP_SOURCE_DIR}/src/mipp.h>
                   $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MIPP/mipp.h>)

install (DIRECTORY "${MIPP_SOURCE_DIR}/src"
         DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/MIPP" COMPONENT MIPP)

install (TARGETS MIPP EXPORT MIPPTargets)

install (EXPORT MIPPTargets DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/MIPP"
         NAMESPACE aff3ct:: COMPONENT MIPP)

include (CPackComponent)

cpack_add_component (MIPP DESCRIPTION "MIPP intrinsics library sources")

add_library (aff3ct::MIPP ALIAS MIPP)

set (MIPP_FOUND TRUE)
