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

OrangesDefaultWarnings
-------------------------

Provides a helper target for configuring some default compiler warnings.

The warning flags are designed to be as strict, verbose, and complete as possible, but "warnings as errors" is not configured by this module.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesDefaultWarnings``

Interface target with default warning flags configured.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesGeneratorExpressions)

#

add_library (OrangesDefaultWarnings INTERFACE)

oranges_make_config_generator_expressions (DEBUG config_is_debug)

set (
    gcclike_comp_opts
    # cmake-format: sortable
    -pedantic
    -pedantic-errors
    -Wall
    -Wcast-align
    -Wconversion
    -Wextra
    -Wno-ignored-qualifiers
    -Wno-missing-field-initializers
    -Wno-unknown-pragmas
    -Woverloaded-virtual
    -Wpedantic
    -Wreorder
    -Wshadow
    -Wsign-compare
    -Wsign-conversion
    -Wstrict-aliasing
    -Wuninitialized
    -Wunreachable-code
    -Wunused-parameter)

set (
    gcc_comp_opts
    # cmake-format: sortable
    -Wno-implicit-fallthrough
    -Wno-maybe-uninitialized
    -Wno-strict-overflow
    -Wpointer-arith
    -Wredundant-decls
    -Wundef
    -Wwrite-strings)

set (
    clang_comp_opts
    # cmake-format: sortable
    --extra-warnings
    -fcolor-diagnostics
    -fdebug-macro
    -pedantic
    -Wbool-conversion
    -Wconditional-uninitialized
    -Wconstant-conversion
    -Wextra-semi
    -Wint-conversion
    -Wnullable-to-nonnull-conversion
    -Wshadow-all
    -Wshift-sign-overflow
    -Wshorten-64-to-32
    -Wunused-variable)

set (gcclike_cxx_opts # cmake-format: sortable
                      -Wnon-virtual-dtor -Wzero-as-null-pointer-constant)

set (gcc_cxx_opts # cmake-format: sortable
                  -Wdelete-non-virtual-dtor -Wnoexcept -Wsuggest-override)

set (clang_cxx_opts
     # cmake-format: sortable
     -Winconsistent-missing-destructor-override -Woverloaded-virtual -Wunused-private-field)

set (
    intel_nonwin
    # cmake-format: sortable
    -w3
    -Wall
    -Wextra-tokens
    -Wformat
    -Wmain
    -Wpointer-arith
    -Wreorder
    -Wreturn-type
    -Wshadow
    -Wsign-compare
    -Wstrict-aliasing
    -Wuninitialized
    -Wwrite-strings)

set (intel_flags "$<IF:$<PLATFORM_ID:Windows>,/W5;/Wall,${intel_nonwin}>")

target_compile_options (
    OrangesDefaultWarnings
    INTERFACE
        # cmake-format: sortable
        "$<$<CXX_COMPILER_ID:MSVC>:/W4;/Wall;/WL;/external:W0;/wd4820;/wd5045>"
        "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:${gcclike_comp_opts}>"
        "$<$<CXX_COMPILER_ID:GNU>:${gcc_comp_opts}>"
        "$<$<CXX_COMPILER_ID:Clang,AppleClang>:${clang_comp_opts}>"
        "$<$<OR:$<COMPILE_LANG_AND_ID:CXX,Clang,AppleClang,GNU>,$<COMPILE_LANG_AND_ID:OBJCXX,Clang,AppleClang,GNU>>:${gcclike_cxx_opts}>"
        "$<$<OR:$<COMPILE_LANG_AND_ID:CXX,GNU>,$<COMPILE_LANG_AND_ID:OBJCXX,GNU>>:${gcc_cxx_opts}>"
        "$<$<OR:$<COMPILE_LANG_AND_ID:CXX,Clang,AppleClang>,$<COMPILE_LANG_AND_ID:OBJCXX,Clang,AppleClang>>:${clang_cxx_opts}>"
        "$<$<CXX_COMPILER_ID:Intel,IntelLLVM>:${intel_flags}>"
        "$<$<AND:$<CXX_COMPILER_ID:ARMCC,ARMClang>,${config_is_debug}>:-g>")

unset (intel_flags)
unset (intel_nonwin)
unset (gcclike_comp_opts)
unset (gcc_comp_opts)
unset (clang_comp_opts)
unset (config_is_debug)
unset (gcclike_cxx_opts)
unset (gcc_cxx_opts)
unset (clang_cxx_opts)

install (TARGETS OrangesDefaultWarnings EXPORT OrangesTargets)

add_library (Oranges::OrangesDefaultWarnings ALIAS OrangesDefaultWarnings)
