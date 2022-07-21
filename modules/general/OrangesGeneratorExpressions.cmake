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

OrangesGeneratorExpressions
-----------------------------

Functions providing generator expression utilities.


Get the list of debug configurations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_get_debug_config_list

  ::

    oranges_get_debug_config_list (<outVar>)

Sets a variable named ``<outVar>`` in the calling scope with the list of debug configurations.

This function queries the global property ``DEBUG_CONFIGURATIONS``, and if it is not set, provides
the value ``Debug``.


Create generator expressions for querying the configuration type
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_make_config_generator_expressions

  ::

    oranges_make_config_generator_expressions ([DEBUG <debugVar>] [RELEASE <releaseVar>])

Creates generator expressions to evaluate if the active configuration is debug or release,
and populates the variables ``<debugVar>`` and ``<releaseVar>`` in the calling scope.

The created generator expressions can be composed like so:

.. code-block:: cmake

    oranges_make_config_generator_expressions (DEBUG config_is_debug
                                               RELEASE config_is_release)

    target_compile_options (myTarget PUBLIC
                            $<${config_is_debug}:-O0>
                            $<${config_is_release}:-O3>)

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

#

function (oranges_get_debug_config_list outVar)

    get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

    if (NOT debug_configs)
        set (debug_configs Debug)
    endif ()

    set (${outVar} ${debug_configs} PARENT_SCOPE)

endfunction ()

#

function (oranges_make_config_generator_expressions)

    set (oneVal DEBUG RELEASE)

    cmake_parse_arguments (ORANGES_ARG "" "${oneVal}" "" ${ARGN})

    oranges_check_for_unparsed_args (ORANGES_ARG)

    oranges_get_debug_config_list (debug_configs)

    set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

    set (config_is_release "$<NOT:${config_is_debug}>")

    if (ORANGES_ARG_DEBUG)
        set (${ORANGES_ARG_DEBUG} "${config_is_debug}" PARENT_SCOPE)
    endif ()

    if (ORANGES_ARG_RELEASE)
        set (${ORANGES_ARG_RELEASE} "${config_is_release}" PARENT_SCOPE)
    endif ()

endfunction ()
