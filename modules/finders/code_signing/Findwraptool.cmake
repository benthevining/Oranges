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

Findwraptool
-------------------------

Find PACE's wraptool code signing program.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- wraptool_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- PACE::wraptool : the wraptool executable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (wraptool PROPERTIES URL "https://paceap.com/pro-audio/"
                        DESCRIPTION "AAX plugin signing tool provided by PACE")

oranges_file_scoped_message_context ("Findwraptool")

#

if (TARGET PACE::wraptool)
    set (wraptool_FOUND TRUE)
else ()
    set (wraptool_FOUND FALSE)

    find_program (WRAPTOOL_PROGRAM wraptool DOC "PACE wraptool program")

    mark_as_advanced (FORCE WRAPTOOL_PROGRAM)

    if (WRAPTOOL_PROGRAM)
        add_executable (wraptool IMPORTED GLOBAL)

        set_target_properties (wraptool PROPERTIES IMPORTED_LOCATION "${WRAPTOOL_PROGRAM}")

        add_executable (PACE::wraptool ALIAS wraptool)

        set (wraptool_FOUND TRUE)
    else ()
        find_package_warning_or_error ("wraptool program cannot be found!")
    endif ()
endif ()
