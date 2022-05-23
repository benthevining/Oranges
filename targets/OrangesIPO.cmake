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

Provides an interface target with interprocedural optimization enabled.

If the variable :variable:`CMAKE_INTERPROCEDURAL_OPTIMIZATION` is defined, it will control this module's behavior - if set to a false value, linking to the ``OrangesIPO`` target does nothing.
If :variable:`CMAKE_INTERPROCEDURAL_OPTIMIZATION` is not defined, CMake's :module:`CheckIPOSupported` module will be used to detect if IPO is supported with the current toolchain, and if not, linking to the ``OrangesIPO`` target does nothing.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesIPO``

Sets up interprocedural optimization flags.

Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:variable:`CMAKE_INTERPROCEDURAL_OPTIMIZATION`

If this variable is set to true, then IPO will be enabled; you can set this variable to false to disable IPO even when linking to this target.

.. seealso ::

    Module :module:`CheckIPOSupported`
        Built-in CMake module for checking if IPO is supported by the current toolchain

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)

add_library (OrangesIPO INTERFACE)

# cmake-format: off
if (NOT (DEFINED CMAKE_INTERPROCEDURAL_OPTIMIZATION
         OR DEFINED CACHE{CMAKE_INTERPROCEDURAL_OPTIMIZATION}))
# cmake-format: on
    include (CheckIPOSupported)
    check_ipo_supported (RESULT CMAKE_INTERPROCEDURAL_OPTIMIZATION)
endif ()

if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    set_target_properties (OrangesIPO PROPERTIES $<BUILD_INTERFACE:INTERPROCEDURAL_OPTIMIZATION ON>)

    message (VERBOSE " -- ENABLING IPO in OrangesIPO target")

    add_feature_info (IPO ON "Enabling interprocedural optimization in OrangesIPO target")
else ()
    # cmake-format: off
    set_target_properties (OrangesIPO PROPERTIES $<BUILD_INTERFACE:INTERPROCEDURAL_OPTIMIZATION OFF>)
    # cmake-format: on

    message (VERBOSE " -- DISABLING IPO in OrangesIPO target")

    add_feature_info (IPO OFF "Enabling interprocedural optimization in OrangesIPO target")
endif ()

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

foreach (config IN LISTS debug_configs)
    string (TOUPPER "${config}" config)

    set_target_properties (OrangesIPO
                           PROPERTIES $<BUILD_INTERFACE:INTERPROCEDURAL_OPTIMIZATION_${config} OFF>)
endforeach ()

install (TARGETS OrangesIPO EXPORT OrangesTargets)

add_library (Oranges::OrangesIPO ALIAS OrangesIPO)