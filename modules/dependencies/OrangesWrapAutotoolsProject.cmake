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

OrangesWrapAutotoolsProject
----------------------------

Functions to integrate a project that uses GNU autotools.


.. command:: autotools_run_configure

  ::

    autotools_run_configure (SOURCE_DIR <sourceDir>
                            [C_FLAGS <c_flags...>]
                            [CXX_FLAGS <cxx_flags...>]
                            [LD_FLAGS <linkerFlags...>]
                            [STATIC] [SHARED])



.. command:: autotools_add_build_target

  ::

    autotools_add_build_target (SOURCE_DIR <sourceDir>
                                TARGET <targetName>
                               [COMMENT <buildComment>])

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

#

function (autotools_run_configure)

    set (options STATIC SHARED)
    set (oneValueArgs SOURCE_DIR)
    set (multiValueArgs C_FLAGS CXX_FLAGS LD_FLAGS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG SOURCE_DIR)

    list (JOIN ORANGES_ARG_C_FLAGS " " c_flags)
    list (JOIN ORANGES_ARG_CXX_FLAGS " " cxx_flags)
    list (JOIN ORANGES_ARG_LD_FLAGS " " ld_flags)

    if (c_flags)
        set (c_flags_arg "CFLAGS=${c_flags}")
    endif ()

    if (cxx_flags)
        set (cxx_flags_arg "CPPFLAGS=${cxx_flags}")
    endif ()

    if (ld_flags)
        set (ld_flags_arg "LDFLAGS=${ld_flags}")
    endif ()

    if (ORANGES_ARG_STATIC)
        set (static_flag --enable-static)
    else ()
        set (static_flag --disable-static)
    endif ()

    if (ORANGES_ARG_SHARED)
        set (shared_flag --enable-shared)
    else ()
        set (shared_flag --disable-shared)
    endif ()

    execute_process (
        COMMAND
            ./configure "CC=${CMAKE_C_COMPILER}" "CXX=${CMAKE_CXX_COMPILER}"
            "${static_flag}" "${shared_flag}" ${c_flags_arg} ${cxx_flags_arg}
            ${ld_flags_arg}
            "--cache-file=${CMAKE_CURRENT_BINARY_DIR}/config.cache"
        WORKING_DIRECTORY "${ORANGES_ARG_SOURCE_DIR}" COMMAND_ECHO STDOUT)

endfunction ()

#

function (autotools_add_build_target)

    set (oneValueArgs SOURCE_DIR TARGET COMMENT)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG SOURCE_DIR TARGET)

    if (NOT ORANGES_ARG_COMMENT)
        set (ORANGES_ARG_COMMENT "Building ${ORANGES_ARG_TARGET}...")
    endif ()

    add_custom_target (
        "${ORANGES_ARG_TARGET}"
        COMMAND make
        WORKING_DIRECTORY "${ORANGES_ARG_SOURCE_DIR}"
        COMMENT "${ORANGES_ARG_COMMENT}"
        VERBATIM USES_TERMINAL)

endfunction ()
