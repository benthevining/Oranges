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

OrangesCoverageFlags
-------------------------

Provides a helper target for configuring coverage flags.

Note that this is a build-only target! You should always link to it using the following command:

.. code-block:: cmake

    target_link_libraries (YourTarget YOUR_SCOPE
        $<BUILD_INTERFACE:Oranges::OrangesAllIntegrations>)

If you get an error similar to: ::

    CMake Error: install(EXPORT "someExport" ...) includes target "yourTarget" which requires target "OrangesAllIntegrations" that is not in any export set.

then this is why. You're linking to OrangesCoverageFlags unconditionally (or with incorrect generator expressions).


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesCoverageFlags

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesCoverageFlags)
    return ()
endif ()

add_library (OrangesCoverageFlags INTERFACE)

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

unset (debug_configs)

set (compiler_gcclike "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>>")

target_compile_options (
    OrangesCoverageFlags
    INTERFACE
        "$<$<AND:$<CXX_COMPILER_ID:MSVC>,${config_is_debug}>:/fsanitize-coverage=edge>"
        "$<$<AND:${compiler_gcclike},${config_is_debug}>:-O0;-g;--coverage>"
        "$<$<AND:$<CXX_COMPILER_ID:GNU>,${config_is_debug}>:-ggdb;-fno-merge-debug-strings;-ftest-coverage>"
        "$<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang>,${config_is_debug}>:-fcoverage-mapping;-fdebug-macro;-g3>"
    )

target_link_options (OrangesCoverageFlags INTERFACE
                     "$<$<AND:${compiler_gcclike},${config_is_debug}>:--coverage>")

unset (config_is_debug)
unset (compiler_gcclike)

install (TARGETS OrangesCoverageFlags EXPORT OrangesTargets)

add_library (Oranges::OrangesCoverageFlags ALIAS OrangesCoverageFlags)
