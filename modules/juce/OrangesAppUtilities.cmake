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

OrangesAppUtilities
-------------------------

Utilities for configuring JUCE apps.
This module provides the functions :command:`lemons_configure_headless_app()` and :command:`lemons_configure_juce_app()`.

.. command:: lemons_configure_headless_app

  ::

    lemons_configure_headless_app ()

	Forwards `${ARGN}` to :command:`lemons_configure_juce_target`.

.. command:: lemons_configure_juce_app

  ::

    lemons_configure_juce_app ()

	Forwards `${ARGN}` to :command:`lemons_configure_juce_target`.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesJuceUtilities)
include (lemons_AggregateTargets)
include (OrangesCmakeDevTools)

lemons_warn_if_not_processing_project ()

#

macro (_lemons_configure_app_internal)
    oranges_add_function_message_context ()

    lemons_configure_juce_target (${ARGN})

    cmake_parse_arguments (LEMONS_APP "" "TARGET" "" ${ARGN})

    _lemons_add_to_all_apps_target (${LEMONS_APP_TARGET})
endmacro ()

#

function (lemons_configure_headless_app)
    oranges_add_function_message_context ()
    _lemons_configure_app_internal (${ARGN})
endfunction ()

#

function (lemons_configure_juce_app)
    oranges_add_function_message_context ()

    _lemons_configure_app_internal (${ARGN})

    if (TARGET Lemons::LemonsAppModules)
        target_link_libraries (${LEMONS_APP_TARGET} PRIVATE Lemons::LemonsAppModules)
    else ()
        message (DEBUG "No target Lemons::LemonsAppModules in call to ${CMAKE_CURRENT_FUNCTION}...")
    endif ()
endfunction ()
