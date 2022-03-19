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

When this module is included, it creates a target that generates a png image of the CMake dependency graph for the current project.

Inclusion style: Once globally, preferably from top-level project

Cache variables:
- ORANGES_DEPS_GRAPH_OUTPUT_TO_SOURCE : if set, the generated png image will be copied to this folder.
The use case is to commit the dependency graph image to the source tree. Defaults to ${CMAKE_SOURCE_DIR}/util.
- ORANGES_DOC_OUTPUT_DIR : The directory where the image will be generated. Defaults to ${CMAKE_SOURCE_DIR}/doc.

]]

# NB. becuase cmake only outputs a dependency graph for the top-level project, I use variables
# CMAKE_SOURCE_DIR and CMAKE_BINARY_DIR in this module.

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

if(NOT PROJECT_IS_TOP_LEVEL)
	message (
		WARNING "OrangesGraphVizConfig.cmake included from non-top-level project ${PROJECT_NAME}!")
endif()

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/CMakeGraphVizOptions.cmake"
				"${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake" @ONLY)

find_package (dot QUIET)

if(NOT ORANGES_DOT)
	message (AUTHOR_WARNING "dot cannot be found, dependency graph images cannot be generated")
	return ()
endif()

set (ORANGES_DEPS_GRAPH_OUTPUT_TO_SOURCE "${CMAKE_SOURCE_DIR}/util"
	 CACHE PATH "Location within the source tree to store the generated dependency graph image")

set (ORANGES_DOC_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/doc"
	 CACHE PATH "Location to output the generated documentation files")

set (dot_file_output "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.dot")
set (graph_image_output "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.png")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/generate_deps_graph_image.cmake"
				generate_deps_graph_image.cmake @ONLY)

add_custom_target (
	DependencyGraph COMMAND "${CMAKE_COMMAND}" -S "${CMAKE_SOURCE_DIR}" -B "${CMAKE_BINARY_DIR}"
							"--graphviz=${dot_file_output}" WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
	VERBATIM USES_TERMINAL)

add_custom_command (
	TARGET DependencyGraph
	POST_BUILD
	COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/generate_deps_graph_image.cmake"
	WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
	DEPENDS "${dot_file_output}"
	COMMENT "Generating dependency graph image..."
	VERBATIM USES_TERMINAL)

set_target_properties (DependencyGraph PROPERTIES ADDITIONAL_CLEAN_FILES "${dot_file_output}")

if(ORANGES_DEPS_GRAPH_OUTPUT_TO_SOURCE)
	add_custom_command (
		TARGET DependencyGraph
		POST_BUILD
		COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${graph_image_output}"
				"${ORANGES_DEPS_GRAPH_OUTPUT_TO_SOURCE}"
		WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
		DEPENDS "${graph_image_output}"
		COMMENT "Copying generated dependency graph image to source tree..."
		VERBATIM USES_TERMINAL)
endif()

install (FILES "${graph_image_output}" "${dot_file_output}" TYPE INFO OPTIONAL
		 COMPONENT "${CMAKE_PROJECT_NAME}_Documentation")

set ("CPACK_COMPONENT_${CMAKE_PROJECT_NAME}_Documentation_DISPLAY_NAME"
	 "${CMAKE_PROJECT_NAME} documentation")

set ("CPACK_COMPONENT_${CMAKE_PROJECT_NAME}_Documentation_DESCRIPTION"
	 "Installs HTML and man-page documentation for ${CMAKE_PROJECT_NAME}")

set ("CPACK_COMPONENT_${CMAKE_PROJECT_NAME}_Documentation_GROUP" Documentation)

set (CPACK_COMPONENT_GROUP_Documentation_DESCRIPTION "Installs all available sets of documentation")

unset (dot_file_output)
unset (graph_image_output)