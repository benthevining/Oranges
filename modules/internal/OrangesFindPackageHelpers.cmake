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

OrangesFindPackageHelpers
--------------------------

Helper functions for internal use inside find modules.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (FindPackageMessage)
include (GNUInstallDirs)

#

macro (find_package_warning_or_error message_text)
    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
        message (FATAL_ERROR "${message_text}")
    endif ()

    if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
        message (WARNING "${message_text}")
    endif ()
endmacro ()

#

macro (find_package_default_component_list)
    if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        set (${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS ${ARGN})
    elseif (All IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        set (${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS ${ARGN})
    endif ()
endmacro ()
