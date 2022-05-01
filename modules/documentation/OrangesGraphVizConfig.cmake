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

#[=======================================================================[.rst:

OrangesGraphVizConfig
-------------------------

When this module is included, it creates a target that generates a png image of the CMake dependency graph for the current project.

Inclusion style: Once globally, preferably from the top-level project

Input variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ${PROJECT_NAME}_DEPS_GRAPH_OUTPUT_TO_SOURCE

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- ORANGES_DOC_OUTPUT_DIR : The directory where the image will be generated. Defaults to ${CMAKE_SOURCE_DIR}/doc.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- DependencyGraph

#]=======================================================================]

# NB. becuase cmake only outputs a dependency graph for the top-level project, I
# use variables CMAKE_SOURCE_DIR and CMAKE_BINARY_DIR in this module.

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("OrangesGraphVizConfig")

if (NOT PROJECT_IS_TOP_LEVEL)
    message (
        WARNING
            "OrangesGraphVizConfig.cmake included from non-top-level project ${PROJECT_NAME}!"
        )
endif ()

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/CMakeGraphVizOptions.cmake"
                "${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake" @ONLY)

find_package (dot MODULE QUIET)

if (NOT ORANGES_DOT)
    message (
        AUTHOR_WARNING
            "dot cannot be found, dependency graph images cannot be generated")
    return ()
endif ()

if ("${${PROJECT_NAME}_DOC_OUTPUT_DIR}" STREQUAL "")
    set (ORANGES_DOC_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/doc"
         CACHE PATH "Location to output the generated documentation files")
else ()
    set (ORANGES_DOC_OUTPUT_DIR "${${PROJECT_NAME}_DOC_OUTPUT_DIR}"
         CACHE PATH "Location to output the generated documentation files")
endif ()

set (input_file
     "${CMAKE_CURRENT_LIST_DIR}/scripts/generate_deps_graph_image.cmake")

configure_file ("${input_file}" generate_deps_graph_image.cmake @ONLY)

set_property (
    DIRECTORY "${}" APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS "${input_file}"
             "${CMAKE_CURRENT_LIST_DIR}/scripts/CMakeGraphVizOptions.cmake")

set (dot_file_output "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.dot")

add_custom_target (
    DependencyGraph
    COMMAND "${CMAKE_COMMAND}" -S "${CMAKE_SOURCE_DIR}" -B "${CMAKE_BINARY_DIR}"
            "--graphviz=${dot_file_output}"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    VERBATIM USES_TERMINAL
    COMMENT "Rerunning CMake to generate dependency graph...")

add_custom_command (
    TARGET DependencyGraph
    POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -P
            "${CMAKE_CURRENT_BINARY_DIR}/generate_deps_graph_image.cmake"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    DEPENDS "${dot_file_output}"
    COMMENT "Generating dependency graph image..."
    VERBATIM USES_TERMINAL)

set_property (
    TARGET DependencyGraph
    APPEND
    PROPERTY ADDITIONAL_CLEAN_FILES
             "${CMAKE_CURRENT_BINARY_DIR}/generate_deps_graph_image.cmake"
             "${dot_file_output}"
             "${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake")

set_target_properties (
    DependencyGraph
    PROPERTIES FOLDER Utility LABELS Utility XCODE_GENERATE_SCHEME OFF
               EchoString "Generating dependency graph...")

if (NOT "${${PROJECT_NAME}_DEPS_GRAPH_OUTPUT_TO_SOURCE}" STREQUAL "")

    set (image_dest "${${PROJECT_NAME}_DEPS_GRAPH_OUTPUT_TO_SOURCE}")

    if (NOT IS_ABSOLUTE "${image_dest}")
        set ("${PROJECT_SOURCE_DIR}/${image_dest}")
    endif ()

    set (graph_image_output "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.png")

    add_custom_command (
        TARGET DependencyGraph
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${graph_image_output}"
                "${image_dest}"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        DEPENDS "${graph_image_output}"
        COMMENT "Copying generated dependency graph image to source tree..."
        VERBATIM USES_TERMINAL)

    unset (image_dest)
endif ()

unset (dot_file_output)
unset (graph_image_output)
