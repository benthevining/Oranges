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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/CMakeGraphVizOptions.cmake"
				"${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake" @ONLY)

find_program (ORANGES_DOT dot)

mark_as_advanced (FORCE ORANGES_DOT)

if(NOT ORANGES_DOT)
	message (AUTHOR_WARNING "dot cannot be found, dependency graph images cannot be generated")
	return ()
endif()

set (ORANGES_DEPS_GRAPH_OUTPUT_TO_SOURCE "${PROJECT_SOURCE_DIR}/util"
	 CACHE PATH "Location within the source tree to store the generated dependency graph image")

set (ORANGES_DOC_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/doc")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/generate_deps_graph_image.cmake"
				generate_deps_graph_image.cmake @ONLY)

add_custom_target (
	DependencyGraph
	COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/generate_deps_graph_image.cmake"
	WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
	DEPENDS "${CMAKE_SOURCE_DIR}/deps_graph.dot" "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.png"
	COMMENT "Generating dependency graph image..."
	VERBATIM USES_TERMINAL)

set_target_properties (
	DependencyGraph
	PROPERTIES ADDITIONAL_CLEAN_FILES
			   "${CMAKE_SOURCE_DIR}/deps_graph.png;${CMAKE_SOURCE_DIR}/deps_graph.dot")

install (FILES "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.png" "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.dot"
		 TYPE INFO OPTIONAL COMPONENT "${PROJECT_NAME}_Documentation")

set ("CPACK_COMPONENT_${PROJECT_NAME}_Documentation_DISPLAY_NAME" "${PROJECT_NAME} documentation")

set ("CPACK_COMPONENT_${PROJECT_NAME}_Documentation_DESCRIPTION"
	 "Installs HTML and man-page documentation for ${PROJECT_NAME}")

set ("CPACK_COMPONENT_${PROJECT_NAME}_Documentation_GROUP" Documentation)

set (CPACK_COMPONENT_GROUP_Documentation_DESCRIPTION "Installs all available sets of documentation")