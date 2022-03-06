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

find_program (lemonsCppLintProgram NAMES cpplint)

mark_as_advanced (FORCE lemonsCppLintProgram)

if(NOT lemonsCppLintProgram)
	return ()
endif()

message (VERBOSE "Using cpplint!")

set (CMAKE_CXX_CPPLINT "${lemonsCppLintProgram}")
set (CMAKE_C_CPPLINT "${lemonsCppLintProgram}")

add_library (OrangesCppLint INTERFACE)

set_target_properties (OrangesCppLint PROPERTIES CXX_CPPLINT "${lemonsCppLintProgram}"
												 C_CPPLINT "${lemonsCppLintProgram}")

oranges_export_alias_target (OrangesCppLint Oranges)

target_link_libraries (OrangesAllIntegrations INTERFACE Oranges::OrangesCppLint)

oranges_install_targets (TARGETS OrangesCppLint EXPORT OrangesTargets OPTIONAL)
