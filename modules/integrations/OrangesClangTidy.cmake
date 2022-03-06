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
include (LemonsCmakeDevTools)

find_program (ORANGES_CLANG_TIDY NAMES clang-tidy)

mark_as_advanced (FORCE ORANGES_CLANG_TIDY)

if(NOT ORANGES_CLANG_TIDY)
	return ()
endif()

message (VERBOSE "Using clang-tidy!")

set (CMAKE_CXX_CLANG_TIDY "${ORANGES_CLANG_TIDY}")
set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

add_library (OrangesClangTidy INTERFACE)

set_target_properties (OrangesClangTidy PROPERTIES EXPORT_COMPILE_COMMANDS ON
												   CXX_CLANG_TIDY "${ORANGES_CLANG_TIDY}")

oranges_export_alias_target (OrangesClangTidy Oranges)

target_link_libraries (OrangesAllIntegrations INTERFACE Oranges::OrangesClangTidy)

oranges_install_targets (TARGETS OrangesClangTidy EXPORT OrangesTargets OPTIONAL)