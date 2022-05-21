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

Findpluginval
-------------------------

Find the pluginval plugin testing tool.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PROGRAM_PLUGINVAL

Path to the pluginval executable

.. cmake:variable:: PLUGINVAL_BUILD_AT_CONFIGURE_TIME

If this is ``ON`` and pluginval cannot be found on the system, then it will be built from source at configure time. Defaults to ``ON``.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Tracktion::pluginval``: The pluginval executable

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)
include (OrangesFetchRepository)
include (LemonsCmakeDevTools)

set_package_properties (pluginval PROPERTIES URL "https://github.com/Tracktion/pluginval"
                        DESCRIPTION "Audio plugin testing and validation tool")

#

oranges_file_scoped_message_context ("Findpluginval")

if (TARGET Tracktion::pluginval)
    set (pluginval_FOUND TRUE)
    return ()
endif ()

set (pluginval_FOUND FALSE)

# TO DO: search the cache location where it would've been built...
find_program (PROGRAM_PLUGINVAL pluginval DOC "pluginval executable")

mark_as_advanced (FORCE PROGRAM_PLUGINVAL)

if (PROGRAM_PLUGINVAL)
    add_executable (pluginval IMPORTED GLOBAL)

    set_target_properties (pluginval PROPERTIES IMPORTED_LOCATION "${PROGRAM_PLUGINVAL}")

    add_executable (Tracktion::pluginval ALIAS pluginval)

    set (pluginval_FOUND TRUE)

    return ()
endif ()

option (PLUGINVAL_BUILD_AT_CONFIGURE_TIME ON
        "Build pluginval from source at configure-time if it can't be found on the system")

if (PLUGINVAL_BUILD_AT_CONFIGURE_TIME)

    if (pluginval_FIND_QUIETLY)
        set (quiet_flag QUIET)
    endif ()

    oranges_fetch_repository (
        NAME pluginval GITHUB_REPOSITORY Tracktion/pluginval GIT_TAG origin/master
        DOWNLOAD_ONLY EXCLUDE_FROM_ALL NEVER_LOCAL ${quiet_flag})

    unset (quiet_flag)

    if (WIN32)
        execute_process (COMMAND "${pluginval_SOURCE_DIR}/install/windows_build.bat")
    else ()
        if (APPLE)
            execute_process (COMMAND "${pluginval_SOURCE_DIR}/install/mac_build")
        else ()
            execute_process (COMMAND "${pluginval_SOURCE_DIR}/install/linux_build")
        endif ()
    endif ()

    unset (CACHE{PLUGINVAL_BUILT_PROGRAM})

    find_program (PLUGINVAL_BUILT_PROGRAM pluginval PATHS "${pluginval_SOURCE_DIR}/bin")

    if (PLUGINVAL_BUILT_PROGRAM)
        add_executable (pluginval IMPORTED GLOBAL)

        set_target_properties (pluginval PROPERTIES IMPORTED_LOCATION "${PLUGINVAL_BUILT_PROGRAM}")

        add_executable (Tracktion::pluginval ALIAS pluginval)

        set (pluginval_FOUND TRUE)
    endif ()
endif ()

if (NOT TARGET Tracktion::pluginval)
    find_package_warning_or_error ("pluginval cannot be found!")
endif ()
