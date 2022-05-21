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

OrangesCcache
-------------------------

Find the ccache compiler cache, and set up a target that uses it as its compiler launcher.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: CCACHE_PROGRAM

Path to the ccache executable

.. cmake:variable:: CCACHE_DISABLE

When ``ON``, ccache is disabled for the entire build and linking against ``ccache::interface`` does nothing. Defaults to ``OFF``.

.. cmake:variable:: CCACHE_OPTIONS

A space-separated list of command line flags to pass to ccache.

Defaults to ``CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=6 CCACHE_MAXSIZE=800M CCACHE_BASEDIR=${CMAKE_SOURCE_DIR} CCACHE_DIR=${CMAKE_SOURCE_DIR}/Cache/ccache/cache``.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``ccache::interface``

Interface library that can be linked against to enable ccache for a target

Target properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``ORANGES_USING_CCACHE``

True if the target is using ccache; otherwise, false or undefined.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)

option (CCACHE_DISABLE "Disable ccache for this build" OFF)

#

oranges_file_scoped_message_context ("Findccache")

#

define_property (
    TARGET INHERITED PROPERTY ORANGES_USING_CCACHE
    BRIEF_DOCS "Boolean that indicates whether this target is using the ccache compiler cache"
    FULL_DOCS "Boolean that indicates whether this target is using the ccache compiler cache")

find_program (CCACHE_PROGRAM ccache DOC "ccache executable")

mark_as_advanced (FORCE CCACHE_PROGRAM)

#

enable_language (CXX)
enable_language (C)

#

set (
    CCACHE_OPTIONS
    "CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=6 CCACHE_MAXSIZE=800M CCACHE_BASEDIR=${CMAKE_SOURCE_DIR} CCACHE_DIR=${CMAKE_SOURCE_DIR}/Cache/ccache/cache"
    CACHE
        STRING
        "Space-separated command line options that will be passed to ccache (as the compiler launcher)"
    )

if (CCACHE_OPTIONS)
    separate_arguments (ccache_options UNIX_COMMAND "${CCACHE_OPTIONS}")
    list (JOIN ccache_options "\n export " CCACHE_EXPORTS)
else ()
    set (CCACHE_EXPORTS "")
endif ()

#

function (_lemons_configure_compiler_launcher language)

    oranges_add_function_message_context ()

    string (TOUPPER "${language}" lang_upper)

    set (CCACHE_COMPILER_BEING_CONFIGURED "${CMAKE_${lang_upper}_COMPILER}")

    set (script_name "launch-${language}")

    configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/launcher.in" "${script_name}" @ONLY
                    NEWLINE_STYLE UNIX)

    set (${language}_script "${CMAKE_CURRENT_BINARY_DIR}/${script_name}" PARENT_SCOPE)
endfunction ()

_lemons_configure_compiler_launcher (c)
_lemons_configure_compiler_launcher (cxx)

unset (CCACHE_EXPORTS)

# TO DO: use cmake for this?
execute_process (COMMAND chmod a+rx "${c_script}" "${cxx_script}")

#

if (NOT TARGET ccache-interface)
    add_library (ccache-interface INTERFACE)
endif ()

if (CCACHE_DISABLE)
    set_target_properties (ccache-interface PROPERTIES ORANGES_USING_CCACHE FALSE)
    message (VERBOSE "Disabling ccache")

    add_feature_info (ccache OFF "Not using the ccache compiler cache")
else ()
    set_target_properties (ccache-interface PROPERTIES ORANGES_USING_CCACHE TRUE)
    message (VERBOSE "Using ccache")

    add_feature_info (ccache ON "Using the ccache compiler cache")

    if (XCODE)
        set_target_properties (
            ccache-interface
            PROPERTIES XCODE_ATTRIBUTE_CC "${c_script}" XCODE_ATTRIBUTE_CXX "${cxx_script}"
                       XCODE_ATTRIBUTE_LD "${c_script}" XCODE_ATTRIBUTE_LDPLUSPLUS "${cxx_script}")
    else ()
        set_target_properties (ccache-interface PROPERTIES C_COMPILER_LAUNCHER "${c_script}"
                                                           CXX_COMPILER_LAUNCHER "${cxx_script}")
    endif ()
endif ()

if (NOT TARGET ccache::interface)
    add_library (ccache::interface ALIAS ccache-interface)
endif ()

install (TARGETS ccache-interface EXPORT OrangesTargets)
