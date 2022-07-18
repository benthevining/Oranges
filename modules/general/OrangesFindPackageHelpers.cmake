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

For convenience, this module also includes the ``FeatureSummary``, ``FindPackageMessage``, and
``FindPackageHandleStandardArgs`` modules.


Resolve a find_package() component list
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: find_package_default_component_list

    ::

        find_package_default_component_list (<validComponents...>)

Pass the list of valid component names to this macro, and it detects if the user requested any invalid
components in their ``find_package()`` call, and raises a warning (if the ``QUIET`` flag wasn't passed
to ``find_package()``).

Additionally, if ``All``, ``ALL``, or ``all`` was passed as a component name by the user to
``find_package()``, then this macro sets the variable ``${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS``
to the full list of valid component names passed to this macro. If the ``All`` component was specified
as a required component in the user's ``find_package()`` call, then this macro sets the variables
``${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_<comp>`` to ``ON`` for each of the valid component names.


Set the MacOS architectures of a prebuilt library
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: find_package_detect_macos_arch

    ::

        find_package_detect_macos_arch (<target> <libPath>)

This function runs ``lipo -archs <libPath>`` and uses the output to set the ``OSX_ARCHITECTURES``
property on the given ``<target>``.

This function does nothing on non-Apple platforms.

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
            OR ALL IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS
            OR all IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
        set (${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS ${__all_find_components})

        if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_All
            OR ${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_ALL
            OR ${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_all)
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

#

function (find_package_detect_macos_arch target libPath)

    if (NOT APPLE)
        return ()
    endif ()

    if (NOT TARGET "${target}")
        return ()
    endif ()

    if (NOT EXISTS "${libPath}")
        return ()
    endif ()

    find_program (PROGRAM_LIPO lipo PATHS ENV PROGRAM_LIPO DOC "Path to the lipo executable")

    if (NOT PROGRAM_LIPO)
        return ()
    endif ()

    execute_process (COMMAND "${PROGRAM_LIPO}" -archs "${libPath}" OUTPUT_VARIABLE lib_archs
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

    # lipo outputs archs separated by whitespace, so use separate_arguments to parse it into a list
    separate_arguments (lib_archs UNIX_COMMAND "${lib_archs}")

    set_target_properties ("${target}" PROPERTIES OSX_ARCHITECTURES "${lib_archs}")

endfunction ()
