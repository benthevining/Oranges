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

OrangesDebugTarget
-------------------------

Provides an interface target with debugging and code coverage flags enabled.

This target's debugging flags are designed to be as verbose as possible.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesDebugTarget

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesDebugTarget)
    message (WARNING "Target Oranges::OrangesDebugTarget already exists!")
    return ()
endif ()

#

add_library (OrangesDebugTarget INTERFACE)

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

unset (debug_configs)

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

set (compiler_gcclike "$<CXX_COMPILER_ID:GNU,Clang,AppleClang>")

set (compiler_gcc "$<CXX_COMPILER_ID:GNU>")

set (compiler_clang "$<CXX_COMPILER_ID:Clang,AppleClang>")

set (compiler_msvc "$<CXX_COMPILER_ID:MSVC>")

set (compiler_arm "$<CXX_COMPILER_ID:ARMCC,ARMClang>")

set (compiler_cray "$<CXX_COMPILER_ID:Cray>")

#

if (WIN32)
    set (intel_cov_flags /Z7 /debug:all)
else ()
    set (intel_cov_flags -g3 -debug all)
endif ()

set (gcclike_flags -O0 -g --coverage)

set (gcc_flags # cmake-format: sortable
               -fno-merge-debug-strings -ftest-coverage -ggdb)

set (clang_flags # cmake-format: sortable
                 -fcoverage-mapping -fdebug-macro -fprofile-instr-generate -g3)

set (msvc_flags # cmake-format: sortable
                /fsanitize-coverage=edge /Z7)

target_compile_options (
    OrangesDebugTarget
    INTERFACE "$<$<AND:${config_is_debug},${compiler_msvc}>:${msvc_flags}>"
              "$<$<AND:${config_is_debug},${compiler_intel}>:${intel_cov_flags}>"
              "$<$<AND:${config_is_debug},${compiler_gcclike}>:${gcclike_flags}>"
              "$<$<AND:${config_is_debug},${compiler_gcc}>:${gcc_flags}>"
              "$<$<AND:${config_is_debug},${compiler_clang}>:${clang_flags}>"
              "$<$<AND:${config_is_debug},${compiler_arm}>:-g>"
              "$<$<AND:${config_is_debug},${compiler_cray}>:-G0>")

unset (intel_cov_flags)
unset (gcclike_flags)
unset (gcc_flags)
unset (clang_flags)
unset (msvc_flags)

target_link_options (OrangesDebugTarget INTERFACE
                     "$<$<AND:${compiler_gcclike},${config_is_debug}>:--coverage>")

include (OrangesGeneratePlatformHeader)

if (PLAT_APPLE)
    target_compile_options (OrangesDebugTarget
                            INTERFACE "$<$<AND:${config_is_debug},${compiler_gcc}>:-gfull>")
endif ()

#

unset (config_is_debug)
unset (compiler_intel)
unset (compiler_gcclike)
unset (compiler_gcc)
unset (compiler_msvc)
unset (compiler_arm)
unset (compiler_cray)

#

install (TARGETS OrangesDebugTarget EXPORT OrangesTargets)

add_library (Oranges::OrangesDebugTarget ALIAS OrangesDebugTarget)
