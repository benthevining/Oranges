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

Findclang-tidy
-------------------------

Find the clang-tidy static analysis tool.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CLANGTIDY_PROGRAM

Path to the clang-tidy executable

.. cmake:variable:: CLANGTIDY_CONFIG_FILE

May specify a path to a ``.clang-tidy`` configuration file that every target linking to ``Clang::clang-tidy-interface`` will use for its clang-tidy checks.
If ``CLANGTIDY_CONFIG_FILE`` is blank, clang-tidy will use its default behavior of searching for a ``.clang-tidy`` file in any parent directory of the source file currently being compiled.
If you set ``CLANGTIDY_CONFIG_FILE`` to the string ``DEFAULT``, then Oranges will provide a default ``.clang-tidy`` file which contains a broad set of checks designed to be as thorough and verbose as possible.

Changes to the value of this variable after this module is included have no effect.

.. cmake:variable:: CLANGTIDY_EXTRA_ARGS

A space-separated list of command line arguments that will be passed to the clang-tidy executable verbatim. Empty by default.

Changes to the value of this variable after this module is included have no effect.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Clang::clang-tidy``

The clang-tidy executable.

``Clang::clang-tidy-interface``

Interface library that can be linked against to enable clang-tidy integrations for a target.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    clang-tidy PROPERTIES
    URL "https://clang.llvm.org/extra/clang-tidy/"
    DESCRIPTION "C++ code linter"
    TYPE OPTIONAL
    PURPOSE "Static analysis")

oranges_file_scoped_message_context ("Findclang-tidy")

set (clang-tidy_FOUND FALSE)

find_program (CLANGTIDY_PROGRAM "clang-tidy" DOC "clang-tidy executable")

mark_as_advanced (FORCE CLANGTIDY_PROGRAM)

set (
    CLANGTIDY_CONFIG_FILE
    ""
    CACHE
        FILEPATH
        "Path to config file for .clang-tidy. Set to DEFAULT to use one provided by Oranges, or leave blank for clang-tidy to discover the project's."
    )

set (
    CLANGTIDY_EXTRA_ARGS
    ""
    CACHE
        STRING
        "A space-separated list of command line arguments that will be passed to the clang-tidy executable verbatim."
    )

if (NOT CLANGTIDY_PROGRAM)
    find_package_warning_or_error ("clang-tidy program cannot be found!")
    return ()
endif ()

if (NOT clang-tidy_FIND_QUIETLY)
    message (VERBOSE "Using clang-tidy!")
endif ()

add_executable (clang-tidy IMPORTED GLOBAL)

set_target_properties (clang-tidy PROPERTIES IMPORTED_LOCATION "${CLANG_TIDY_PROGRAM}")

add_executable (Clang::clang-tidy ALIAS clang-tidy)

set (clang-tidy_FOUND TRUE)

if (NOT TARGET Clang::clang-tidy-interface)

    add_library (clang-tidy-interface INTERFACE)

    set (clangtidy_cmd "${CLANG_TIDY_PROGRAM}")

    if (CLANGTIDY_CONFIG_FILE)
        if ("${CLANGTIDY_CONFIG_FILE}" MATCHES DEFAULT)
            set (clangtidy_cmd
                 "${clangtidy_cmd};--config-file=${CMAKE_CURRENT_LIST_DIR}/scripts/.clang-tidy")
        else ()
            set (clangtidy_cmd "${clangtidy_cmd};--config-file=${CLANGTIDY_CONFIG_FILE}")
        endif ()
    endif ()

    if (CLANGTIDY_EXTRA_ARGS)
        separate_arguments (clangtidy_xtra_args UNIX_COMMAND "${CLANGTIDY_EXTRA_ARGS}")

        set (clangtidy_cmd "${clangtidy_cmd};${clangtidy_xtra_args}")

        unset (clangtidy_xtra_args)
    endif ()

    set_target_properties (clang-tidy-interface PROPERTIES EXPORT_COMPILE_COMMANDS ON
                                                           CXX_CLANG_TIDY "${clangtidy_cmd}")

    unset (clangtidy_cmd)

    add_library (Clang::clang-tidy-interface ALIAS clang-tidy-interface)
endif ()
