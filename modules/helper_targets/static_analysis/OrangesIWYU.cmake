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

OrangesIWYU
-------------------------

Set up the include-what-you-use static analysis tool.

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

``IWYU::interface``

Interface library that can be linked against to enable include-what-you-use integrations for a target


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)

find_program (IWYU_PROGRAM NAMES include-what-you-use iwyu DOC "include-what-you-use executable")

mark_as_advanced (FORCE IWYU_PROGRAM)

set (
    IWYU_EXTRA_ARGS
    "--update_comments;--cxx17ns"
    CACHE
        STRING
        "A space-separated list of command line arguments that will be passed to the include-what-you-use executable."
    )

if (NOT TARGET IWYU::interface)
    add_library (include-what-you-use-interface INTERFACE)

    if (IWYU_PROGRAM)
        set (iwyu_cmd "${IWYU_PROGRAM}")

        foreach (xtra_arg IN LISTS IWYU_EXTRA_ARGS)
            set (iwyu_cmd "${iwyu_cmd};-Xiwyu;${xtra_arg}")
            unset (xtra_arg)
        endforeach ()

        set_target_properties (include-what-you-use-interface PROPERTIES CXX_INCLUDE_WHAT_YOU_USE
                                                                         "${iwyu_cmd}")

        unset (iwyu_cmd)

        message (VERBOSE "include-what-you-use enabled")

        add_feature_info (include-what-you-use ON "include-what-you-use static analysis tool")
    else ()
        message (VERBOSE "include-what-you-use could not be found")

        add_feature_info (include-what-you-use OFF "include-what-you-use static analysis tool")
    endif ()

    add_library (IWYU::interface ALIAS include-what-you-use-interface)
endif ()
