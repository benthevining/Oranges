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

find_program (lemonsCppLintProgram NAMES cpplint)

if(NOT lemonsCppLintProgram)
	return ()
endif()

message (VERBOSE "Using cpplint!")

set (CMAKE_CXX_CPPLINT "${lemonsCppLintProgram}")
set (CMAKE_C_CPPLINT "${lemonsCppLintProgram}")

add_library (OrangesCppLint INTERFACE)

set_target_properties (OrangesCppLint PROPERTIES CXX_CPPLINT "${lemonsCppLintProgram}"
												 C_CPPLINT "${lemonsCppLintProgram}")

target_link_libraries (OrangesAllIntegrations INTERFACE OrangesCppLint)

add_library (Oranges::OrangesCppLint ALIAS OrangesCppLint)

install (TARGETS OrangesCppLint EXPORT OrangesTargets OPTIONAL)
