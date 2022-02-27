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

add_library (LemonsDefaultTarget INTERFACE)

set_target_properties (
	LemonsDefaultTarget
	PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON EXPORT_COMPILE_COMMANDS ON
			   VISIBILITY_INLINES_HIDDEN ON)

target_compile_features (LemonsDefaultTarget INTERFACE cxx_std_20)

if((CMAKE_CXX_COMPILER_ID MATCHES "MSVC") OR (CMAKE_CXX_COMPILER_FRONTEND_VARIANT MATCHES "MSVC"))

	# config flags
	target_compile_options (
		LemonsDefaultTarget INTERFACE $<IF:$<CONFIG:Debug>,/Od /Zi,/Ox>
									  $<$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">:/MP> /EHsc)

	# warnings
	target_compile_options (LemonsDefaultTarget INTERFACE "/W4")

	# LTO
	target_compile_options (
		LemonsDefaultTarget
		INTERFACE $<$<CONFIG:Release>:$<IF:$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">,-GL,-flto>>
		)

	target_link_libraries (
		LemonsDefaultTarget
		INTERFACE $<$<CONFIG:Release>:$<$<STREQUAL:"${CMAKE_CXX_COMPILER_ID}","MSVC">:-LTCG>>)

	set_target_properties (LemonsDefaultTarget PROPERTIES MSVC_RUNTIME_LIBRARY
														  "MultiThreaded$<$<CONFIG:Debug>:Debug>")

	# string (REGEX REPLACE "/W3" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}) string (REGEX REPLACE "-W3"
	# "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})

elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang|GNU")

	# config flags
	target_compile_options (LemonsDefaultTarget INTERFACE $<$<CONFIG:Debug>:-g -O0>
														  $<$<CONFIG:Release>:-O3>)

	# warnings
	target_compile_options (
		LemonsDefaultTarget
		INTERFACE -Wall
				  -Wuninitialized
				  -Wsign-conversion
				  -Wunreachable-code
				  -Wstrict-aliasing
				  -Wunused-parameter
				  -Wsign-compare
				  -Wno-ignored-qualifiers
				  -Wcast-align
				  -Wno-missing-field-initializers
				  -Wpedantic)

	if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
		target_compile_options (
			LemonsDefaultTarget
			INTERFACE -Wextra
					  -Wno-implicit-fallthrough
					  -Wno-maybe-uninitialized
					  -Wredundant-decls
					  -Wno-strict-overflow
					  -Wshadow
					  $<$<COMPILE_LANGUAGE:CXX>:
					  -Woverloaded-virtual
					  -Wreorder
					  -Wzero-as-null-pointer-constant>)
	else()
		target_compile_options (
			LemonsDefaultTarget
			INTERFACE -Wshadow-all
					  -Wshorten-64-to-32
					  -Wconversion
					  -Wint-conversion
					  -Wconditional-uninitialized
					  -Wconstant-conversion
					  -Wbool-conversion
					  -Wextra-semi
					  -Wshift-sign-overflow
					  -Wnullable-to-nonnull-conversion
					  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:OBJCXX>>:
					  -Wzero-as-null-pointer-constant
					  -Wunused-private-field
					  -Woverloaded-virtual
					  -Wreorder
					  -Winconsistent-missing-destructor-override>)
	endif()

	# LTO
	if(NOT MINGW)
		target_compile_options (LemonsDefaultTarget INTERFACE $<$<CONFIG:Release>:-flto>)
		target_link_libraries (LemonsDefaultTarget INTERFACE $<$<CONFIG:Release>:-flto>)
	endif()
else()
	message (WARNING "Unknown compiler!")
endif()

#
# IPO

include (CheckIPOSupported)

check_ipo_supported (RESULT ipo_supported OUTPUT output)

if(ipo_supported)
	set_target_properties (LemonsDefaultTarget PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)

	message (VERBOSE "Enabling IPO")
endif()

#
# MacOS options

if(APPLE)
	set_target_properties (
		LemonsDefaultTarget
		PROPERTIES XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
				   XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}")
	target_compile_definitions (LemonsDefaultTarget INTERFACE JUCE_USE_VDSP_FRAMEWORK=1)
	target_compile_options (LemonsDefaultTarget
							INTERFACE "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
	target_link_options (LemonsDefaultTarget INTERFACE
						 "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")

	if(IOS)
		set_target_properties (
			LemonsDefaultTarget
			PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "./" XCODE_ATTRIBUTE_INSTALL_PATH
													 "$(LOCAL_APPS_DIR)"
					   XCODE_ATTRIBUTE_SKIP_INSTALL NO XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO)

		option (LEMONS_IOS_SIMULATOR "Build for an iOS simulator, rather than a real device" ON)

		if(LEMONS_IOS_SIMULATOR)
			set_target_properties (
				LemonsDefaultTarget
				PROPERTIES XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "\"iPhone Developer\""
						   OSX_ARCHITECTURES "i386;x86_64")
		else() # Options for building for a real device
			set_target_properties (
				LemonsDefaultTarget PROPERTIES # XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
											   OSX_ARCHITECTURES "armv7;armv7s;arm64;i386;x86_64")
		endif()
	else()
		option (LEMONS_MAC_UNIVERSAL_BINARY "Builds for x86_64 and arm64" ON)

		if(LEMONS_MAC_UNIVERSAL_BINARY AND XCODE)

			execute_process (COMMAND uname -m RESULT_VARIABLE result OUTPUT_VARIABLE osx_native_arch
							 OUTPUT_STRIP_TRAILING_WHITESPACE)

			if("${osx_native_arch}" STREQUAL "arm64")
				set_target_properties (LemonsDefaultTarget PROPERTIES OSX_ARCHITECTURES
																	  "x86_64;arm64")
				message (VERBOSE "Enabling universal binary")
			endif()
		endif()
	endif()
else()
	set_target_properties (LemonsDefaultTarget PROPERTIES INSTALL_RPATH $ORIGIN)
endif()

#
# Integrations

include (LemonsClangTidy)

lemons_use_clang_tidy_for_target (LemonsDefaultTarget)

include (LemonsCppCheck)

lemons_use_cppcheck_for_target (LemonsDefaultTarget)

include (LemonsCppLint)

lemons_use_cpplint_for_target (LemonsDefaultTarget)

include (LemonsIncludeWhatYouUse)

lemons_use_iwyu_for_target (LemonsDefaultTarget)

#

add_library (Lemons::LemonsDefaultTarget ALIAS LemonsDefaultTarget)
