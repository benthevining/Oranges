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

    oranges_add_build_type_macros (TARGET <targetName>
                                   BASE_NAME <baseName>
                                   SCOPE <PUBLIC|PRIVATE|INTERFACE>)

Adds some preprocessor definitions to the specified target which describe the current build type being built.

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

function (oranges_add_build_type_macros)

    set (oneValueArgs TARGET BASE_NAME SCOPE)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    oranges_assert_target_argument_is_target (ORANGES_ARG)
    lemons_require_function_arguments (ORANGES_ARG BASE_NAME SCOPE)

    string (TOUPPER "${ORANGES_ARG_BASE_NAME}" base_name)

    get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

    if (NOT debug_configs)
        set (debug_configs Debug)
    endif ()

    set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

    unset (debug_configs)

    set (config_is_release "$<NOT:${config_is_debug}>")

    # cmake-format: off
    target_compile_definitions (
    "${ORANGES_ARG_TARGET}"
    "${ORANGES_ARG_SCOPE}"
        "$<${config_is_debug}:${base_name}_DEBUG=1>"
        "$<${config_is_debug}:${base_name}_RELEASE=0>"
        "$<${config_is_release}:${base_name}_DEBUG=0>"
        "$<${config_is_release}:${base_name}_RELEASE=1>"
        "${base_name}_BUILD_TYPE=\"$<CONFIG>\"")
    # cmake-format: on

endfunction ()
