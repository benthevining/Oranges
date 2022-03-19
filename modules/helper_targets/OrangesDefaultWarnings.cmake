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

#[[

This module creates the target Oranges::OrangesDefaultWarnings.

Inclusion style: once globally

Targets:
- Oranges::OrangesDefaultWarnings

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

add_library (OrangesDefaultWarnings INTERFACE)

target_compile_options (OrangesDefaultWarnings INTERFACE $<$<CXX_COMPILER_ID:MSVC>:/W4>)

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wall
			  -Wcast-align
			  -Wno-ignored-qualifiers
			  -Wno-missing-field-initializers
			  -Wpedantic
			  -Wuninitialized
			  -Wunreachable-code
			  -Wunused-parameter
			  -Wreorder
			  -Wsign-conversion
			  -Wstrict-aliasing
			  -Wsign-compare>)

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE $<$<CXX_COMPILER_ID:GNU>:-Wextra
			  -Wno-implicit-fallthrough
			  -Wno-maybe-uninitialized
			  -Wno-strict-overflow
			  -Wredundant-decls
			  -Wshadow
			  $<$<COMPILE_LANGUAGE:CXX>:Woverloaded-virtual,-Wzero-as-null-pointer-constant>>)

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE $<$<CXX_COMPILER_ID:Clang,AppleClang>:-Wbool-conversion
			  -Wconditional-uninitialized
			  -Wconversion
			  -Wconstant-conversion
			  -Wextra-semi
			  -Wint-conversion
			  -Wnullable-to-nonnull-conversion
			  -Wshadow-all
			  -Wshift-sign-overflow
			  -Wshorten-64-to-32
			  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:OBJCXX>>:
			  -Wzero-as-null-pointer-constant
			  -Wunused-private-field
			  -Woverloaded-virtual
			  -Winconsistent-missing-destructor-override>>)

oranges_export_alias_target (OrangesDefaultWarnings Oranges)

oranges_install_targets (TARGETS OrangesDefaultWarnings EXPORT OrangesTargets OPTIONAL)
