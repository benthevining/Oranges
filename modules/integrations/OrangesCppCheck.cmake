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

find_program (lemonsCppCheckProgram NAMES cppcheck)

mark_as_advanced (FORCE lemonsCppCheckProgram)

if(NOT lemonsCppCheckProgram)
	return ()
endif()

message (VERBOSE "Using cppcheck!")

set (CMAKE_CXX_CPPCHECK "${lemonsCppCheckProgram};--suppress=preprocessorErrorDirective")
set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

add_library (OrangesCppCheck INTERFACE)

set_target_properties (OrangesCppCheck PROPERTIES EXPORT_COMPILE_COMMANDS ON
												  CXX_CPPCHECK "${lemonsCppCheckProgram}")

add_library (Oranges::OrangesCppCheck ALIAS OrangesCppCheck)

target_link_libraries (OrangesAllIntegrations INTERFACE Oranges::OrangesCppCheck)

oranges_install_targets (TARGETS OrangesCppCheck EXPORT OrangesTargets OPTIONAL)
