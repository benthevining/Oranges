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

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

if (WIN32)
    set (intel_cov_flags /Z7 /debug:all)
else ()
    set (intel_cov_flags -g3 -debug all)
endif ()

set (gcclike_flags -O0 -g --coverage)

set (gcc_flags # cmake-format: sortable
               -fno-merge-debug-strings -ftest-coverage -ggdb)

set (clang_flags # cmake-format: sortable
                 -fcoverage-mapping -fdebug-macro -g3)

target_compile_options (
    OrangesCoverageFlags
    INTERFACE "$<$<AND:$<CXX_COMPILER_ID:MSVC>,${config_is_debug}>:/fsanitize-coverage=edge>"
              "$<$<AND:${compiler_gcclike},${config_is_debug}>:${gcclike_flags}>"
              "$<$<AND:$<CXX_COMPILER_ID:GNU>,${config_is_debug}>:${gcc_flags}>"
              "$<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang>,${config_is_debug}>:${clang_flags}>"
              "$<$<AND:${compiler_intel},${config_is_debug}>:${intel_cov_flags}>")

target_link_options (OrangesCoverageFlags INTERFACE
                     "$<$<AND:${compiler_gcclike},${config_is_debug}>:--coverage>")

unset (gcc_flags)
unset (clang_flags)
unset (compiler_gcclike)
unset (intel_cov_flags)
unset (intel_cov_flags)

target_compile_options (
    OrangesCoverageFlags
    INTERFACE "$<$<AND:$<CXX_COMPILER_ID:ARMCC,ARMClang>,${config_is_debug}>:-g>")

target_compile_options (OrangesCoverageFlags
                        INTERFACE $<$<AND:$<CXX_COMPILER_ID:Cray>,${config_is_debug}>:-G 0>)

unset (config_is_debug)

install (TARGETS OrangesCoverageFlags EXPORT OrangesTargets)

add_library (Oranges::OrangesCoverageFlags ALIAS OrangesCoverageFlags)
