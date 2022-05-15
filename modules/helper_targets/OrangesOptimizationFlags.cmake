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
              "$<$<AND:${compiler_msvc},${config_is_release}>:/Ox;/Ot>"
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
    INTERFACE "$<$<CXX_COMPILER_ID:GNU>:-march=native>"
              "$<$<AND:${compiler_gcclike},${config_is_debug}>:-O0>"
              "$<$<AND:$<CXX_COMPILER_ID:GNU>,${config_is_debug}>:-Og>"
              "$<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:MINSIZEREL>>:-Oz;-fconserve-stack>"
              "$<$<AND:${compiler_gcclike},$<OR:${config_is_debug},$<CONFIG:RELWITHDEBINFO>>>:-g>"
              "$<$<AND:${compiler_gcclike},${config_is_release}>:-O3;-Ofast>"
              "$<$<AND:${compiler_gcclike},$<CONFIG:MINSIZEREL>>:-Os>")

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
                              -fvectorize)

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE
        "$<$<AND:${compiler_gcclike},${config_is_debug}>:${gcclike_opts}>"
        "$<$<AND:$<CXX_COMPILER_ID:GNU>,${config_is_release}>:${gcc_optimization_flags}>"
        "$<$<AND:$<CXX_COMPILER_ID:Clang,AppleClang>,${config_is_release}>:${clang_optimization_flags}>"
    )

unset (gcclike_opts)
unset (compiler_gcclike)
unset (gcc_optimization_flags)
unset (clang_optimization_flags)

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

if (WIN32)
    set (intel_debug_flags /0d)
    set (intel_minsize_flags /Os)
    set (intel_reldeb_flags /debug:all)

    set (intel_release_flags # cmake-format: sortable
                             /fast /fp:fast=2 /O3 /Ox /Quse-intel-optimized-headers /Qvec)

else ()
    set (intel_debug_flags -O0)
    set (intel_minsize_flags -Os)
    set (intel_reldeb_flags -debug all)

    set (
        intel_release_flags
        # cmake-format: sortable
        -fast
        -ffp-contract=fast
        -finline
        -finline-functions
        -fno-math-errno
        -fp-model=fast
        -O3
        -Ofast
        -use-intel-optimized-headers
        -vec)

endif ()

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<$<AND:${compiler_intel},${config_is_debug}>:${intel_debug_flags}>"
              "$<$<AND:${compiler_intel},${config_is_release}>:${intel_release_flags}>"
              "$<$<AND:${compiler_intel},$<CONFIG:MINSIZEREL>>:${intel_minsize_flags}>"
              "$<$<AND:${compiler_intel},$<CONFIG:RELWITHDEBINFO>>:${intel_reldeb_flags}>")

unset (intel_reldeb_flags)
unset (intel_debug_flags)
unset (intel_release_flags)
unset (intel_minsize_flags)

set (compiler_arm "$<CXX_COMPILER_ID:ARMCC,ARMClang>")

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<${compiler_arm}:-finline-functions>"
              "$<$<AND:${compiler_arm},${config_is_debug}>:-O0;-g>"
              "$<$<AND:${compiler_arm},${config_is_release}>:-O3;-fvectorize>"
              "$<$<AND:${compiler_arm},$<CONFIG:MINSIZEREL>>:-0z>")

set (compiler_cray "$<CXX_COMPILER_ID:Cray>")

set (cray_debug_opts vector0,scalar0,fp0)

set (cray_release_opts vector3,scalar3,cache3,aggress,flex_mp=tolerant,wp,fp3)

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<$<AND:${compiler_cray},${config_is_debug}>:-O0>"
              "$<$<AND:${compiler_cray},${config_is_release}>:-O3>"
              $<$<AND:${compiler_cray},${config_is_debug}>:-h
              ${cray_debug_opts}>
              $<$<AND:${compiler_cray},${config_is_release}>:-h
              ${cray_release_opts}>)

unset (compiler_cray)
unset (cray_release_opts)
unset (config_is_debug)
unset (config_is_release)

install (TARGETS OrangesOptimizationFlags EXPORT OrangesTargets)

add_library (Oranges::OrangesOptimizationFlags ALIAS OrangesOptimizationFlags)
