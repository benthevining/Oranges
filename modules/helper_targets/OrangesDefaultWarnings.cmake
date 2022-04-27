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

Note that this is a build-only target! You should always link to it using the following command:
```cmake
target_link_libraries (YourTarget YOUR_SCOPE
	$<BUILD_INTERFACE:Oranges::OrangesDefaultWarnings>)
```
If you get an error similar to:
```
CMake Error: install(EXPORT "someExport" ...) includes target "yourTarget" which requires target "OrangesDefaultWarnings" that is not in any export set.
```
then this is why. You're linking to OrangesDefaultWarnings unconditionally (or with incorrect generator expressions).


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesDefaultWarnings

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesDefaultWarnings)
	return ()
endif ()

add_library (OrangesDefaultWarnings INTERFACE)

target_compile_options (OrangesDefaultWarnings
						INTERFACE $<$<CXX_COMPILER_ID:MSVC>:/W4>)

set (
	gcclike_comp_opts
	# cmake-format: sortable
	-Wall
	-Wcast-align
	-Wno-ignored-qualifiers
	-Wno-missing-field-initializers
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

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:${gcclike_comp_opts}>")

unset (gcclike_comp_opts)

set (
	gcc_comp_opts
	# cmake-format: sortable
	-Wextra -Wno-implicit-fallthrough -Wno-maybe-uninitialized
	-Wno-strict-overflow -Wredundant-decls)

target_compile_options (OrangesDefaultWarnings
						INTERFACE "$<$<CXX_COMPILER_ID:GNU>:${gcc_comp_opts}>")

unset (gcc_comp_opts)

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE
		"$<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wzero-as-null-pointer-constant>")

set (
	clang_cxx_opts
	# cmake-format: sortable
	-Wbool-conversion
	-Wconditional-uninitialized
	-Wconstant-conversion
	-Wconversion
	-Wextra-semi
	-Wint-conversion
	-Wnon-virtual-dtor
	-Wnullable-to-nonnull-conversion
	-Wshadow-all
	-Wshift-sign-overflow
	-Wshorten-64-to-32
	-Wunused-variable)

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE "$<$<CXX_COMPILER_ID:Clang,AppleClang>:${clang_cxx_opts}>")

set (
	clang_cxx_opts
	# cmake-format: sortable
	-Winconsistent-missing-destructor-override -Woverloaded-virtual
	-Wunused-private-field -Wzero-as-null-pointer-constant)

target_compile_options (
	OrangesDefaultWarnings
	INTERFACE
		"$<$<COMPILE_LANG_AND_ID:CXX,Clang,AppleClang>:${clang_cxx_opts}>"
		"$<$<COMPILE_LANG_AND_ID:OBJCXX,Clang,AppleClang>:${clang_cxx_opts}>")

unset (clang_cxx_opts)

add_library (Oranges::OrangesDefaultWarnings ALIAS OrangesDefaultWarnings)
