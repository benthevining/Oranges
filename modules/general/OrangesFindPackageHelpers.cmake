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
include (FindPackageHandleStandardArgs)

#

macro (find_package_default_component_list)
    set (__all_find_components ${ARGN})

    if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        set (${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS ${__all_find_components})
    elseif (All IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS
            OR ALL IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        set (${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS ${__all_find_components})

        if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_All
            OR ${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_ALL)
            foreach (__comp_name IN LISTS __all_find_components)
                set (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_${__comp_name} ON)
            endforeach ()
        endif ()
    endif ()

    foreach (__comp_name IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        if (NOT "${__comp_name}" IN_LIST __all_find_components)
            if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
                message (
                    WARNING
                        "Package ${CMAKE_FIND_PACKAGE_NAME} - unknown component ${__comp_name} requested!"
                    )
            endif ()

            list (REMOVE_ITEM ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS "${__comp_name}")
        endif ()
    endforeach ()

    unset (__all_find_components)
    unset (__comp_name)
endmacro ()
