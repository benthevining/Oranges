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

Findinclude-what-you-use
-------------------------

Find the include-what-you-use static analysis tool.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: IWYU_PROGRAM

Path to the include-what-you-use executable

.. cmake:variable:: IWYU_EXTRA_ARGS

A semicolon-separated list of command line arguments that will be passed to the include-what-you-use executable.
For each argument in this list, the IWYU command line is actually appended with ``-Xiwyu <arg>``.
Defaults to ``--update_comments;--cxx17ns``.

Changes to the value of this variable after this module is included have no effect.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Google::include-what-you-use``

include-what-you-use executable

``Google::include-what-you-use-interface``

Interface library that can be linked against to enable include-what-you-use integrations for a target


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    include-what-you-use PROPERTIES
    URL "https://include-what-you-use.org/"
    DESCRIPTION "Static analysis for C++ includes"
    TYPE OPTIONAL
    PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findinclude-what-you-use")

set (include-what-you-use_FOUND FALSE)

find_program (IWYU_PROGRAM NAMES include-what-you-use iwyu DOC "include-what-you-use executable")

mark_as_advanced (FORCE IWYU_PROGRAM)

set (
    IWYU_EXTRA_ARGS
    "--update_comments;--cxx17ns"
    CACHE
        STRING
        "A space-separated list of command line arguments that will be passed to the include-what-you-use executable."
    )

if (NOT IWYU_PROGRAM)
    find_package_warning_or_error ("include-what-you-use program cannot be found!")
    return ()
endif ()

if (NOT include-what-you-use_FIND_QUIETLY)
    message (VERBOSE "Using include-what-you-use!")
endif ()

add_executable (include-what-you-use IMPORTED GLOBAL)

set_target_properties (include-what-you-use PROPERTIES IMPORTED_LOCATION "${IWYU_PROGRAM}")

add_executable (Google::include-what-you-use ALIAS include-what-you-use)

set (include-what-you-use_FOUND TRUE)

if (NOT TARGET Google::include-what-you-use-interface)
    add_library (include-what-you-use-interface INTERFACE)

    set (iwyu_cmd "${IWYU_PROGRAM}")

    foreach (xtra_arg IN LISTS IWYU_EXTRA_ARGS)
        set (iwyu_cmd "${iwyu_cmd};-Xiwyu;${xtra_arg}")
        unset (xtra_arg)
    endforeach ()

    set_target_properties (include-what-you-use-interface PROPERTIES CXX_INCLUDE_WHAT_YOU_USE
                                                                     "${iwyu_cmd}")

    unset (iwyu_cmd)

    add_library (Google::include-what-you-use-interface ALIAS include-what-you-use-interface)
endif ()
