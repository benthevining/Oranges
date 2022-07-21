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

OrangesBuildTypeMacros
----------------------------

This module provides the function :command:`oranges_add_build_type_macros() <oranges_add_build_type_macros>`.

.. command:: oranges_add_build_type_macros

  ::

    oranges_add_build_type_macros (<targetName>
                                  [BASE_NAME <baseName>]
                                  [SCOPE <PUBLIC|PRIVATE|INTERFACE>])

Adds some preprocessor definitions to the specified target which describe the current build type being built.

Options:

``BASE_NAME``
 Prefix used for each macro added to the target. Defaults to ``<targetName>``.

``SCOPE``
 Scope with which the compile definitions will be added to the target.
 Defaults to ``INTERFACE`` for interface library targets, ``PRIVATE`` for executables, and ``PUBLIC`` for all other target types.


This function adds the following preprocessor definitions, where ``<baseName>`` is all uppercase:

.. table:: Build type macros

+------------------------+-------------------------------------+
| Macro name             | Value                               |
+========================+=====================================+
| <baseName>_DEBUG       | 0 or 1                              |
+------------------------+-------------------------------------+
| <baseName>_RELEASE     | 0 or 1                              |
+------------------------+-------------------------------------+
| <baseName>__BUILD_TYPE | String literal, the exact name      |
|                        | of the selected build configuration |
+------------------------+-------------------------------------+

.. note::

    Each macro will always be defined to a value, so you should use ``#if`` to check their values, and not ``#ifdef``.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

#

function (oranges_add_build_type_macros target)

    if (NOT TARGET "${target}")
        message (WARNING "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
        return ()
    endif ()

    set (oneValueArgs BASE_NAME SCOPE)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${target}")
    endif ()

    string (TOUPPER "${ORANGES_ARG_BASE_NAME}" base_name)

    get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

    if (NOT debug_configs)
        set (debug_configs Debug)
    endif ()

    set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

    unset (debug_configs)

    set (config_is_release "$<NOT:${config_is_debug}>")

    if (NOT ORANGES_ARG_SCOPE)
        get_target_property (target_type "${target}" TYPE)

        if ("${target_type}" STREQUAL INTERFACE_LIBRARY)
            set (ORANGES_ARG_SCOPE INTERFACE)
        elseif ("${target_type}" STREQUAL EXECUTABLE)
            set (ORANGES_ARG_SCOPE PUBLIC)
        else ()
            set (ORANGES_ARG_SCOPE PRIVATE)
        endif ()

        unset (target_type)
    endif ()

    # cmake-format: off
    target_compile_definitions (
    "${target}"
    "${ORANGES_ARG_SCOPE}"
        "$<${config_is_debug}:${base_name}_DEBUG=1>"
        "$<${config_is_debug}:${base_name}_RELEASE=0>"
        "$<${config_is_release}:${base_name}_DEBUG=0>"
        "$<${config_is_release}:${base_name}_RELEASE=1>"
        "${base_name}_BUILD_TYPE=\"$<CONFIG>\"")
    # cmake-format: on

endfunction ()
