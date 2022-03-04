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

include (OrangesAllIntegrations)

find_program (lemonsClangTidyProgram NAMES clang-tidy)

if(NOT lemonsClangTidyProgram)
	return ()
endif()

message (VERBOSE "Using clang-tidy!")

set (CMAKE_CXX_CLANG_TIDY "${lemonsClangTidyProgram}")
set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

add_library (OrangesClangTidy INTERFACE)

set_target_properties (OrangesClangTidy PROPERTIES EXPORT_COMPILE_COMMANDS ON
												   CXX_CLANG_TIDY "${lemonsClangTidyProgram}")

target_link_libraries (OrangesAllIntegrations INTERFACE OrangesClangTidy)

add_library (Oranges::OrangesClangTidy ALIAS OrangesClangTidy)

install (TARGETS OrangesClangTidy EXPORT OrangesTargets OPTIONAL)
