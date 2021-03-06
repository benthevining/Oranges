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

Note that Oranges' default warning flags are provided in a separate target in the :module:`OrangesDefaultWarnings` module.
You can link to only this target to configure debugging and coverage flags while providing your own warnings.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesDebugTarget``

Interface target with debugging and code coverage flags specified.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesGeneratorExpressions)

#

add_library (OrangesDebugTarget INTERFACE)

oranges_make_config_generator_expressions (DEBUG config_is_debug)

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

set (compiler_gcclike "$<CXX_COMPILER_ID:GNU,Clang,AppleClang>")

set (compiler_gcc "$<CXX_COMPILER_ID:GNU>")

set (compiler_clang "$<CXX_COMPILER_ID:Clang,AppleClang>")

set (compiler_msvc "$<CXX_COMPILER_ID:MSVC>")

set (compiler_arm "$<CXX_COMPILER_ID:ARMCC,ARMClang>")

set (compiler_cray "$<CXX_COMPILER_ID:Cray>")

#

set (gcclike_flags -O0 -g --coverage)

set (gcc_flags # cmake-format: sortable
               -fno-merge-debug-strings -ftest-coverage -ggdb)

set (clang_flags # cmake-format: sortable
                 -fcoverage-mapping -fdebug-macro -fprofile-instr-generate -g3)

set (msvc_flags # cmake-format: sortable
                /fsanitize-coverage=edge /Z7)

set (intel_flags "$<IF:$<PLATFORM_ID:Windows>,/Z7;/debug:all,-g3;-debug;all>")

target_compile_options (
    OrangesDebugTarget
    INTERFACE "$<$<AND:${config_is_debug},${compiler_msvc}>:${msvc_flags}>"
              "$<$<AND:${config_is_debug},${compiler_intel}>:${intel_flags}>"
              "$<$<AND:${config_is_debug},${compiler_gcclike}>:${gcclike_flags}>"
              "$<$<AND:${config_is_debug},${compiler_gcc}>:${gcc_flags}>"
              "$<$<AND:${config_is_debug},${compiler_gcc},$<PLATFORM_ID:Apple>>:-gfull>"
              "$<$<AND:${config_is_debug},${compiler_clang}>:${clang_flags}>"
              "$<$<AND:${config_is_debug},${compiler_arm}>:-g>"
              "$<$<AND:${config_is_debug},${compiler_cray}>:-G0>")

target_link_options (OrangesDebugTarget INTERFACE
                     "$<$<AND:${compiler_gcclike},${config_is_debug}>:--coverage>")

install (TARGETS OrangesDebugTarget EXPORT OrangesTargets)

add_library (Oranges::OrangesDebugTarget ALIAS OrangesDebugTarget)

unset (intel_flags)
unset (gcclike_flags)
unset (gcc_flags)
unset (clang_flags)
unset (msvc_flags)
unset (config_is_debug)
unset (compiler_intel)
unset (compiler_gcclike)
unset (compiler_gcc)
unset (compiler_msvc)
unset (compiler_arm)
unset (compiler_cray)
