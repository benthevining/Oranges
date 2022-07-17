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

OrangesIPO
-------------------------

Provides a function to enable IPO, if supported.

.. command:: oranges_enable_ipo

    ::

        oranges_enable_ipo (TARGET <target>
                           [INCLUDE_DEBUG])

Enables interprocedural optimization for the given ``<target>`` if the :variable:`CMAKE_INTERPROCEDURAL_OPTIMIZATION` is
set to ``ON``. If this variable is ``OFF``, then calling this function does nothing.

IPO is explicitly disabled for all debug configurations, unless the ``INCLUDE_DEBUG`` flag is passed.


Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:variable:`CMAKE_INTERPROCEDURAL_OPTIMIZATION`

If this variable is set to OFF, then calling :command:`oranges_enable_ipo` does nothing.

.. seealso ::

    Module :module:`CheckIPOSupported`
        Built-in CMake module for checking if IPO is supported by the current toolchain

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesGeneratorExpressions)

# cmake-format: off
if (NOT (DEFINED CMAKE_INTERPROCEDURAL_OPTIMIZATION
         OR DEFINED CACHE{CMAKE_INTERPROCEDURAL_OPTIMIZATION}))
    if(DEFINED ENV{CMAKE_INTERPROCEDURAL_OPTIMIZATION})
        set (CMAKE_INTERPROCEDURAL_OPTIMIZATION "$ENV{CMAKE_INTERPROCEDURAL_OPTIMIZATION}")
    else()
        include (CheckIPOSupported)
        check_ipo_supported (RESULT CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    endif()
endif ()
# cmake-format: on

#

function (oranges_enable_ipo)

    cmake_parse_arguments (ORANGES_ARG "INCLUDE_DEBUG" "TARGET" "" ${ARGN})

    if (NOT TARGET "${ORANGES_ARG_TARGET}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${ORANGES_ARG_TARGET}' does not exist!"
            )
    endif ()

    if (NOT CMAKE_INTERPROCEDURAL_OPTIMIZATION)

        message (
            VERBOSE
            "${CMAKE_CURRENT_FUNCTION} - disabling IPO for target ${ORANGES_ARG_TARGET} because CMAKE_INTERPROCEDURAL_OPTIMIZATION is OFF"
            )

        set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)

        return ()

    endif ()

    message (VERBOSE "${CMAKE_CURRENT_FUNCTION} - enabling IPO for target ${ORANGES_ARG_TARGET}")

    set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)

    if (ORANGES_ARG_INCLUDE_DEBUG)
        return ()
    endif ()

    oranges_get_debug_config_list (debug_configs)

    foreach (config IN LISTS debug_configs)

        string (TOUPPER "${config}" config)

        set_target_properties ("${ORANGES_ARG_TARGET}"
                               PROPERTIES INTERPROCEDURAL_OPTIMIZATION_${config} OFF)
    endforeach ()

endfunction ()
