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

OrangesOptimizationFlags
-------------------------

Provides an interface target with some configuration-aware compiler-specific optimization flags.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesOptimizationFlags

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesOptimizationFlags)
    return ()
endif ()

add_library (OrangesOptimizationFlags INTERFACE)

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

unset (debug_configs)

set (config_is_release "$<NOT:${config_is_debug}>")

set (compiler_msvc "$<CXX_COMPILER_ID:MSVC>")

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<${compiler_msvc}:/Oi>"
              "$<$<AND:${compiler_msvc},${config_is_debug}>:/Od;/Zi>"
              "$<$<AND:${compiler_msvc},${config_is_release}>:/fp:fast;/GL;/Gw;/Qpar>"
              "$<$<AND:${compiler_msvc},${config_is_release},$<NOT:$<CONFIG:MINSIZEREL>>>:/Ox;/Ot>"
              "$<$<AND:${compiler_msvc},$<CONFIG:MINSIZEREL>>:/O1;/Os>")

target_link_options (
    OrangesOptimizationFlags
    INTERFACE
    "$<${compiler_msvc}:/OPT:REF>"
    "$<$<AND:${compiler_msvc},${config_is_debug}>:/OPT:NOICF>"
    "$<$<AND:${compiler_msvc},${config_is_release}>:/LTCG;/OPT:ICF>"
    "$<$<AND:${compiler_msvc},$<CONFIG:RELWITHDEBINFO>>:/DEBUG>")

unset (compiler_msvc)

set (compiler_gcclike "$<CXX_COMPILER_ID:Clang,AppleClang,GNU>")

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE
        "$<$<CXX_COMPILER_ID:GNU>:-march=native>"
        "$<$<AND:${compiler_gcclike},${config_is_debug}>:-O0>"
        "$<$<AND:$<CXX_COMPILER_ID:GNU>,${config_is_debug}>:-Og>"
        "$<$<AND:${compiler_gcclike},$<CONFIG:MINSIZEREL>>:-Os>"
        "$<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:MINSIZEREL>>:-Oz;-fconserve-stack>"
        "$<$<AND:${compiler_gcclike},$<OR:${config_is_debug},$<CONFIG:RELWITHDEBINFO>>>:-g>"
        "$<$<AND:${compiler_gcclike},${config_is_release},$<NOT:$<CONFIG:MINSIZEREL>>>:-O3;-Ofast>")

set (
    gcclike_opts
    # cmake-format: sortable
    -ffast-math
    -ffinite-loops
    -ffinite-math-only
    -ffp-contract=fast
    -fno-math-errno
    -funroll-loops
    -funsafe-math-optimizations)

set (
    gcc_optimization_flags
    # cmake-format: sortable
    -faggressive-loop-optimizations
    -fgcse-after-reload
    -fgcse-las
    -fgcse-lm
    -fgcse-sm
    -floop-interchange
    -fmodulo-sched
    -fmodulo-sched-allow-regmoves)

set (clang_optimization_flags # cmake-format: sortable
                              -fast -fastcp -fastf -fvectorize)

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE
        "$<$<AND:${compiler_gcclike},${config_is_debug}>:${gcclike_opts}>"
        "$<$<AND:$<CXX_COMPILER_ID:GNU>,${config_is_release}>:${gcc_optimization_flags}>"
        "$<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang>,${config_is_release}>:${clang_optimization_flags}>"
    )

#[[
note: for ARM NEON on GCC/Clang:
-mfpu=neon -funsafe-math-optimizations
]]

unset (gcclike_opts)
unset (config_is_debug)
unset (config_is_release)
unset (compiler_gcclike)
unset (gcc_optimization_flags)
unset (clang_optimization_flags)

install (TARGETS OrangesOptimizationFlags EXPORT OrangesTargets)

add_library (Oranges::OrangesOptimizationFlags ALIAS OrangesOptimizationFlags)
