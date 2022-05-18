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

Findcppcheck
-------------------------

Find the cppcheck static analysis tool.

Cache variables:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CPPCHECK_PROGRAM

Path to the cppcheck executable.

.. cmake:variable:: CPPCHECK_ENABLE

List of cppcheck checks to enable. Defaults to ``warning;style;performance;portability``.

Changes to the value of this variable after this module is included have no effect.

.. cmake:variable:: CPPCHECK_DISABLE

List of cppcheck checks to disable. Defaults to ``unmatchedSuppression;missingIncludeSystem;unusedStructMember;unreadVariable;preprocessorErrorDirective;unknownMacro``.

Changes to the value of this variable after this module is included have no effect.

.. cmake:variable:: CPPCHECK_EXTRA_ARGS

A space-separated list of command line arguments that will be passed to the cppcheck executable verbatim. Empty by default.

Changes to the value of this variable after this module is included have no effect.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``cppcheck::cppcheck``

The cppcheck executable

``cppcheck::cppcheck-interface``

Interface library that can be linked against to enable cppcheck integrations for a target

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    cppcheck PROPERTIES
    URL "https://cppcheck.sourceforge.io/"
    DESCRIPTION "C++ code linter"
    TYPE OPTIONAL
    PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findcppcheck")

set (CPPCHECK_ENABLE "warning;style;performance;portability"
     CACHE STRING "List of cppcheck checks to enable")

set (
    CPPCHECK_DISABLE
    "unmatchedSuppression;missingIncludeSystem;unusedStructMember;unreadVariable;preprocessorErrorDirective;unknownMacro"
    CACHE STRING "List of cppcheck checks to disable")

set (
    CPPCHECK_EXTRA_ARGS
    ""
    CACHE
        STRING
        "A space-separated list of command line arguments that will be passed to the cppcheck executable verbatim."
    )

find_program (CPPCHECK_PROGRAM NAMES cppcheck DOC "cppcheck executable")

mark_as_advanced (FORCE CPPCHECK_PROGRAM)

set (cppcheck_FOUND FALSE)

if (NOT CPPCHECK_PROGRAM)
    find_package_warning_or_error ("cppcheck program cannot be found!")
    return ()
endif ()

if (NOT cppcheck_FIND_QUIETLY)
    message (VERBOSE "Using cppcheck!")
endif ()

add_executable (cppcheck IMPORTED GLOBAL)

set_target_properties (cppcheck PROPERTIES IMPORTED_LOCATION "${CPPCHECK_PROGRAM}")

add_executable (cppcheck::cppcheck ALIAS cppcheck)

set (cppcheck_FOUND TRUE)

if (NOT TARGET cppcheck::cppcheck-interface)

    set (cppcheck_cmd "${CPPCHECK_PROGRAM};--inline-suppr")

    foreach (enable_check IN LISTS CPPCHECK_ENABLE)
        list (APPEND cppcheck_cmd "--enable=${enable_check}")
    endforeach ()

    foreach (disable_check IN LISTS CPPCHECK_DISABLE)
        list (APPEND cppcheck_cmd "--suppress=${disable_check}")
    endforeach ()

    if (CPPCHECK_EXTRA_ARGS)
        separate_arguments (cppcheck_xtra_args UNIX_COMMAND "${CPPCHECK_EXTRA_ARGS}")

        set (cppcheck_cmd "${cppcheck_cmd};${cppcheck_xtra_args}")

        unset (cppcheck_xtra_args)
    endif ()

    add_library (cppcheck-interface INTERFACE)

    set_target_properties (cppcheck-interface PROPERTIES EXPORT_COMPILE_COMMANDS ON
                                                         CXX_CPPCHECK "${cppcheck_cmd}")

    unset (cppcheck_cmd)

    add_library (cppcheck::cppcheck-interface ALIAS cppcheck-interface)
endif ()
