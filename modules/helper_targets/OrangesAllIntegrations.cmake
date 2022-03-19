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

This module creates the target Oranges::OrangesAllIntegrations and searches for the following packages:
- ccache
- clang-tidy
- cppcheck
- cpplint
- include-what-you-use

Inclusion style: once globally

Targets:
- Oranges::OrangesAllIntegrations

]]

include_guard (GLOBAL)

find_package (ccache QUIET)
find_package (clang-tidy QUIET)
find_package (cppcheck QUIET)
find_package (cpplint QUIET)
find_package (include-what-you-use QUIET)

add_library (OrangesAllIntegrations INTERFACE)

target_link_libraries (
	OrangesAllIntegrations
	INTERFACE $<TARGET_NAME_IF_EXISTS:ccache::ccache-interface>
			  $<TARGET_NAME_IF_EXISTS:Clang::clang-tidy-interface>
			  $<TARGET_NAME_IF_EXISTS:cppcheck::cppcheck-interface>
			  $<TARGET_NAME_IF_EXISTS:Google::cpplint-interface>
			  $<TARGET_NAME_IF_EXISTS:Google::include-what-you-use-interface>)

oranges_export_alias_target (OrangesAllIntegrations Oranges)

install (TARGETS OrangesAllIntegrations EXPORT OrangesTargets)
