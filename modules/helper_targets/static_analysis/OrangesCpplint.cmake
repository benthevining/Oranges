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

OrangesCpplint
-------------------------

Set up the cpplint static analysis tool.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CPPLINT_PROGRAM

Path to the cpplint executable

.. cmake:variable:: CPPLINT_IGNORE

A list of cpplint checks to ignore; accepts regex. Defaults to ``-whitespace;-legal;-build;-runtime/references;-readability/braces;-readability/todo``.

Changes to the value of this variable after this module is included have no effect.

.. cmake:variable:: CPPLINT_VERBOSITY

cpplint verbosity level. Defaults to 0.

From the cpplint docs:

::

    Specify a number 0-5 to restrict errors to certain verbosity levels.
    Errors with lower verbosity levels have lower confidence and are more
    likely to be false positives.

Changes to the value of this variable after this module is included have no effect.

.. cmake:variable:: CPPLINT_EXTRA_ARGS

A space-separated list of command line arguments that will be passed to the cpplint executable verbatim. Empty by default.

Changes to the value of this variable after this module is included have no effect.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``cpplint::interface``

Interface library that can be linked against to enable cpplint integrations for a target

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)

set (CPPLINT_IGNORE
     "-whitespace;-legal;-build;-runtime/references;-readability/braces;-readability/todo"
     CACHE STRING "List of cpplint checks to ignore")

set (CPPLINT_VERBOSITY 0 CACHE STRING "cpplint verbosity level")

set_property (CACHE CPPLINT_VERBOSITY PROPERTY STRINGS "0;1;2;3;4;5")

set (
    CPPLINT_EXTRA_ARGS
    ""
    CACHE
        STRING
        "A space-separated list of command line arguments that will be passed to the cpplint executable verbatim."
    )

find_program (CPPLINT_PROGRAM NAMES cpplint DOC "cpplint executable")

mark_as_advanced (FORCE CPPLINT_PROGRAM)

if (NOT TARGET cpplint-interface)
    add_library (cpplint-interface INTERFACE)
endif ()

if (CPPLINT_PROGRAM)
    set (cpplint_cmd "${CPPLINT_PROGRAM};--verbose=${CPPLINT_VERBOSITY}")

    if (CPPLINT_IGNORE)
        list (JOIN CPPLINT_IGNORE "," cpplint_ignr)

        set (cpplint_cmd "${cpplint_cmd};--filter=${cpplint_ignr}")

        unset (cpplint_ignr)
    endif ()

    if (CPPLINT_EXTRA_ARGS)
        separate_arguments (cpplint_xtra_args UNIX_COMMAND "${CPPLINT_EXTRA_ARGS}")

        set (cpplint_cmd "${cpplint_cmd};${cpplint_xtra_args}")

        unset (cpplint_xtra_args)
    endif ()

    set_target_properties (cpplint-interface PROPERTIES CXX_CPPLINT "${cpplint_cmd}"
                                                        C_CPPLINT "${cpplint_cmd}")

    unset (cpplint_cmd)

    message (VERBOSE "cpplint found")

    add_feature_info (cpplint ON "cpplint static analysis tool")
else ()
    message (VERBOSE "cpplint could not be found")

    add_feature_info (cpplint OFF "cpplint static analysis tool")
endif ()

if (NOT TARGET cpplint::interface)
    add_library (cpplint::interface ALIAS cpplint-interface)
endif ()

install (TARGETS cpplint-interface EXPORT OrangesTargets)
