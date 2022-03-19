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

This find module locates the dot executable.

Targets:
- Graphviz::dot

Output variables:
- dot_FOUND

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (FeatureSummary)

set_package_properties (dot PROPERTIES URL "https://graphviz.org/"
						DESCRIPTION "Graph image creation tool")

set (dot_FOUND FALSE)

find_program (ORANGES_DOT dot)

mark_as_advanced (FORCE ORANGES_DOT)

if(NOT ORANGES_DOT)
	find_package_warning_or_error ("dot program cannot be found!")
	return ()
endif()

add_executable (dot IMPORTED GLOBAL)

set_target_properties (dot PROPERTIES IMPORTED_LOCATION "${ORANGES_DOT}")

add_executable (Graphviz::dot ALIAS dot)

set (dot_FOUND TRUE)
