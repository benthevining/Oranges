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

.. cmake:variable:: CPPLINT_VERBOSITY

cpplint verbosity level. Defaults to 0.

From the cpplint docs:

::

    Specify a number 0-5 to restrict errors to certain verbosity levels.
    Errors with lower verbosity levels have lower confidence and are more
    likely to be false positives.


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

find_program (CPPLINT_PROGRAM NAMES cpplint DOC "cpplint executable")

mark_as_advanced (FORCE CPPLINT_PROGRAM CPPLINT_IGNORE CPPLINT_VERBOSITY)

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

    list (JOIN CPPLINT_IGNORE "," CPPLINT_IGNORE)

    set_target_properties (
        cpplint-interface
        PROPERTIES CXX_CPPLINT
                   "${CPPLINT_PROGRAM};--verbose=${CPPLINT_VERBOSITY};--filter=${CPPLINT_IGNORE}"
                   C_CPPLINT
                   "${CPPLINT_PROGRAM};--verbose=${CPPLINT_VERBOSITY};--filter=${CPPLINT_IGNORE}")

    add_library (Google::cpplint-interface ALIAS cpplint-interface)
endif ()
