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

If the configuration being built is in the :prop_gbl:`DEBUG_CONFIGURATIONS` property, then this target adds the equivalent of ``-O0``.

Otherwise, this target adds optimization flags that are designed to be as performant as possible, even at the expense of accuracy.
For example, in compilers that support various floating point modes or options, the fastest option available is chosen.

If the configuration being built is ``MINSIZEREL``, then all optimization flags that don't affect binary size are still added,
and any extra flags available to tell the compiler to optimize for size are also added.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesOptimizationFlags``

Interface target with configuration-specific optimization flags configured.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesGeneratePlatformHeader)
include (OrangesGeneratorExpressions)

add_library (OrangesOptimizationFlags INTERFACE)

oranges_make_config_generator_expressions (DEBUG config_is_debug RELEASE config_is_release)

set (config_minsizerel "$<CONFIG:MINSIZEREL>")
set (config_relwdeb "$<CONFIG:RELWITHDEBINFO>")

#
# MSVC

set (compiler_msvc "$<CXX_COMPILER_ID:MSVC>")

# cmake-format: off
target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<${compiler_msvc}:/Oi>"
              "$<$<AND:${compiler_msvc},${config_is_debug}>:/Od;/Zi>"
              "$<$<AND:${compiler_msvc},${config_is_release}>:/fp:fast;/GL;/Gw;/Qpar;/Ox;/Ot>"
              "$<$<AND:${compiler_msvc},${config_minsizerel}>:/O1;/Os>")
# cmake-format: on

target_link_options (
    OrangesOptimizationFlags
    INTERFACE
    "$<${compiler_msvc}:/OPT:REF>"
    "$<$<AND:${compiler_msvc},${config_is_debug}>:/OPT:NOICF>"
    "$<$<AND:${compiler_msvc},${config_is_release}>:/LTCG;/OPT:ICF>"
    "$<$<AND:${compiler_msvc},${config_relwdeb}>:/DEBUG>")

unset (compiler_msvc)

#
# GCC/Clang

set (compiler_gcclike "$<CXX_COMPILER_ID:Clang,AppleClang,GNU>")
set (compiler_gcc "$<CXX_COMPILER_ID:GNU>")
set (compiler_clang "$<CXX_COMPILER_ID:Clang,AppleClang>")

if (PLAT_SSE)
    target_compile_options (OrangesOptimizationFlags INTERFACE "$<${compiler_gcc}:-msse>")
elseif (PLAT_AVX)
    target_compile_options (OrangesOptimizationFlags INTERFACE "$<${compiler_gcc}:-mavx>")
elseif (PLAT_ARM_NEON)
    # the -mfpu=neon option only works when building for ARM, so we can't use it if building a MacOS
    # universal binary
    target_compile_options (
        OrangesOptimizationFlags
        INTERFACE
            "$<$<AND:${compiler_gcc},$<STREQUAL:$<TARGET_PROPERTY:OSX_ARCHITECTURES>,arm64>>:-mfpu=neon>"
        )
endif ()

set (
    gcclike_opts
    # cmake-format: sortable
    -ffast-math
    -ffinite-math-only
    -ffp-contract=fast
    -fno-math-errno
    -funroll-loops
    -funsafe-math-optimizations
    -O3
    -Ofast)

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

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<$<AND:${config_is_release},${compiler_gcclike}>:${gcclike_opts}>"
              "$<$<AND:${config_is_release},${compiler_gcc}>:${gcc_optimization_flags}>"
              "$<$<AND:${config_is_release},${compiler_clang}>:-fvectorize>"
              "$<$<AND:${config_is_debug},${compiler_clang}>:-O0>"
              "$<$<AND:${config_is_debug},${compiler_gcc}>:-Og>"
              "$<$<AND:${config_minsizerel},${compiler_clang}>:-Os>"
              "$<$<AND:${config_minsizerel},${compiler_gcc}>:-Oz;-fconserve-stack>"
              "$<$<CXX_COMPILER_ID:AppleClang,GNU>:-ffinite-loops>")

unset (gcclike_opts)
unset (gcc_optimization_flags)
unset (compiler_gcclike)
unset (compiler_gcc)
unset (compiler_clang)

#
# Intel

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

set (intel_debug_flags "$<IF:$<PLATFORM_ID:Windows>,/0d,-O0>")

set (intel_minsize_flags "$<IF:$<PLATFORM_ID:Windows>,/Os,-Os>")

set (intel_reldeb_flags "$<IF:$<PLATFORM_ID:Windows>,/debug:all,-debug;all>")

set (intel_rel_win # cmake-format: sortable
                   /fast /fp:fast=2 /O3 /Ox /Quse-intel-optimized-headers /Qvec)

set (
    intel_rel_nonwin
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

set (intel_release_flags "$<IF:$<PLATFORM_ID:Windows>,${intel_rel_win},${intel_rel_nonwin}>")

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<$<AND:${compiler_intel},${config_is_debug}>:${intel_debug_flags}>"
              "$<$<AND:${compiler_intel},${config_is_release}>:${intel_release_flags}>"
              "$<$<AND:${compiler_intel},${config_minsizerel}>:${intel_minsize_flags}>"
              "$<$<AND:${compiler_intel},${config_relwdeb}>:${intel_reldeb_flags}>")

unset (intel_rel_win)
unset (intel_rel_nonwin)
unset (intel_reldeb_flags)
unset (intel_debug_flags)
unset (intel_release_flags)
unset (intel_minsize_flags)
unset (compiler_intel)

#
# ARM

set (compiler_arm "$<CXX_COMPILER_ID:ARMCC,ARMClang>")

target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<${compiler_arm}:-finline-functions>"
              "$<$<AND:${compiler_arm},${config_is_debug}>:-O0;-g>"
              "$<$<AND:${compiler_arm},${config_is_release}>:-O3;-fvectorize>"
              "$<$<AND:${compiler_arm},${config_minsizerel}>:-0z>")

unset (compiler_arm)

#
# Cray

set (compiler_cray "$<CXX_COMPILER_ID:Cray>")

set (cray_debug_opts vector0,scalar0,fp0)

set (cray_release_opts vector3,scalar3,cache3,aggress,flex_mp=tolerant,wp,fp3)

# cmake-format: off
target_compile_options (
    OrangesOptimizationFlags
    INTERFACE "$<$<AND:${compiler_cray},${config_is_debug}>:-O0>"
              "$<$<AND:${compiler_cray},${config_is_release}>:-O3>"
              $<$<AND:${compiler_cray},${config_is_debug}>:-h ${cray_debug_opts}>
              $<$<AND:${compiler_cray},${config_is_release}>:-h ${cray_release_opts}>)
# cmake-format: on

unset (compiler_cray)
unset (cray_debug_opts)
unset (cray_release_opts)
unset (config_is_debug)
unset (config_is_release)
unset (config_minsizerel)
unset (config_relwdeb)

install (TARGETS OrangesOptimizationFlags EXPORT OrangesTargets)

add_library (Oranges::OrangesOptimizationFlags ALIAS OrangesOptimizationFlags)
