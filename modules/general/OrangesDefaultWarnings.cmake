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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

add_library (OrangesDefaultWarnings INTERFACE)

if((CMAKE_CXX_COMPILER_ID MATCHES "MSVC") OR (CMAKE_CXX_COMPILER_FRONTEND_VARIANT MATCHES "MSVC"))

	target_compile_options (OrangesDefaultWarnings INTERFACE "/W4")

elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang|GNU")

	# warnings
	target_compile_options (
		OrangesDefaultWarnings
		INTERFACE -Wall
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
				  -Wsign-compare)

	if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
		target_compile_options (
			OrangesDefaultWarnings
			INTERFACE -Wextra
					  -Wno-implicit-fallthrough
					  -Wno-maybe-uninitialized
					  -Wno-strict-overflow
					  -Wredundant-decls
					  -Wshadow
					  $<$<COMPILE_LANGUAGE:CXX>:Woverloaded-virtual,-Wzero-as-null-pointer-constant>
			)
	else()
		target_compile_options (
			OrangesDefaultWarnings
			INTERFACE -Wbool-conversion
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
					  -Winconsistent-missing-destructor-override>)
	endif()

else()
	message (WARNING "Unknown compiler!")
endif()

oranges_export_alias_target (OrangesDefaultWarnings Oranges)

oranges_install_targets (TARGETS OrangesDefaultWarnings EXPORT OrangesTargets OPTIONAL)
