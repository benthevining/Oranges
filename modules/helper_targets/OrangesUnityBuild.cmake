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

OrangesUnityBuild
-------------------------

Provides a helper target for configuring a target as a unity build.

Note that this is a build-only target! You should always link to it using the following command:

.. code-block:: cmake

    target_link_libraries (YourTarget YOUR_SCOPE
        $<BUILD_INTERFACE:Oranges::OrangesAllIntegrations>)

If you get an error similar to: ::

    CMake Error: install(EXPORT "someExport" ...) includes target "yourTarget" which requires target "OrangesAllIntegrations" that is not in any export set.

then this is why. You're linking to OrangesUnityBuild unconditionally (or with incorrect generator expressions).


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesUnityBuild

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesUnityBuild)
    return ()
endif ()

add_library (OrangesUnityBuild INTERFACE)

# cmake-format: off
set_target_properties (OrangesUnityBuild PROPERTIES
                        UNITY_BUILD_MODE BATCH
                        UNITY_BUILD ON)
# cmake-format: on

install (TARGETS OrangesUnityBuild EXPORT OrangesTargets)

add_library (Oranges::OrangesUnityBuild ALIAS OrangesUnityBuild)
