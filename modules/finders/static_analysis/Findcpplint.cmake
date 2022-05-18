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

Findcpplint
-------------------------

Find the cpplint static analysis tool.

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

``Google::cpplint``

The cpplint executable

``Google::cpplint-interface``

Interface library that can be linked against to enable cpplint integrations for a target

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    cpplint PROPERTIES
    URL "https://github.com/google/styleguide"
    DESCRIPTION "C++ code linter"
    TYPE OPTIONAL
    PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findcpplint")

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

set (cpplint_FOUND FALSE)

if (NOT CPPLINT_PROGRAM)
    find_package_warning_or_error ("cpplint program cannot be found!")
    return ()
endif ()

if (NOT cpplint_FIND_QUIETLY)
    message (VERBOSE "Using cpplint!")
endif ()

add_executable (cpplint IMPORTED GLOBAL)

set_target_properties (cpplint PROPERTIES IMPORTED_LOCATION "${CPPLINT_PROGRAM}")

add_executable (Google::cpplint ALIAS cpplint)

set (cpplint_FOUND TRUE)

if (NOT TARGET Google::cpplint-interface)

    add_library (cpplint-interface INTERFACE)

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

    add_library (Google::cpplint-interface ALIAS cpplint-interface)
endif ()
