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

OrangesGraphviz
-------------------------

This module provides the function :command:`oranges_add_graphviz_target() <oranges_add_graphviz_target>`, which adds a custom target to generate Graphviz graphs depicting CMake's build graph.

.. note::

    Graphviz's ``dot`` tool is required to generate the output images. A path to its executable can manually be set using the :variable:`PROGRAM_DOT` cache variable.

.. command:: oranges_add_graphviz_target

    ::

        oranges_add_graphviz_target ([TARGET <targetName>] [ALL]
                                     [OUTPUT_DIR <outputDirectory>]
                                     [SOURCE_DIR <srcDir>]
                                     [BINARY_DIR <binDir>]
                                     [EXTRA_CMAKE_OPTIONS <options...>]
                                     [GRAPHVIZ_CONFIG_FILE <configFile>]
                                     [COPY_GRAPH_TO <filename>])

All arguments are optional.

``OUTPUT_DIR`` is the directory in which the generated .dot file and image will be placed. The image itself will be at ``<outputDirectory>/deps_graph.png``. If not defined, defaults to ``${CMAKE_CURRENT_BINARY_DIR}``.

``TARGET`` is the name of the custom target that, when built, will invoke dot and generate the actual image. If not defined, defaults to ``${PROJECT_NAME}DependencyGraph``.

If the ``ALL`` flag is given, the custom target created will be built with CMake's ``All`` target.

Because CMake only generates one dependency graph for its whole build graph, the way this function works is that its ``TARGET`` invokes another configuration of CMake in a child process, just to generate the build graph for this function's output graph image.
Therefore, you can specify a custom ``SOURCE_DIR`` and ``BINARY_DIR`` for this child invocation of CMake. If not specified, they default to ``${CMAKE_SOURCE_DIR}`` and ``${CMAKE_CURRENT_BINARY_DIR}/Graphviz``, respectively.
I recommend that you set ``SOURCE_DIR`` to ``${PROJECT_SOURCE_DIR}``, and ``BINARY_DIR`` to something specific for Graphviz generation and not used by the rest of your parent build.

In the child CMake invocation, the variable :variable:`ORANGES_IN_GRAPHVIZ_CONFIG` will be defined to ``ON``.

``EXTRA_CMAKE_OPTIONS`` is a list of extra command line arguments that will be forwarded verbatim to the child invocation of CMake.

The ``GRAPHVIZ_CONFIG_FILE`` argument allows you to specify your own `CMakeGraphVizOptions.cmake <https://cmake.org/cmake/help/latest/module/CMakeGraphVizOptions.html>`_ file.
CMake searches for this file in both the source and binary directories (which will be ``SOURCE_DIR`` and ``BINARY_DIR`` in the child invocation of CMake), and it simply sets some variables that CMake uses to configure Graphviz's output.

If you don't provide your own ``GRAPHVIZ_CONFIG_FILE``, this function will check if one exists already in ``srcDir`` or ``binDir``, and if not, will generate a default one for you and copy it to ``<binDir>`` so that the child CMake finds it.
In the default generated config file, the graph is named ``${PROJECT_NAME}``, custom targets are shown, and the per-target and dependers information is not generated.
The generated file will be placed at ``<binDir>/CMakeGraphVizOptions.cmake``.

If you do specify a ``GRAPHVIZ_CONFIG_FILE``, if you don't provide an absolute path, it will be interpreted relative to the current directory (``${CMAKE_CURRENT_LIST_DIR}``).
If your custom config file is not already in ``srcDir`` or ``binDir``, it will be copied to ``<binDir>/CMakeGraphVizOptions.cmake``.

``GRAPHVIZ_CONFIG_FILE`` must be specified if a CMakeGraphVizOptions.cmake file does not exist in ``srcDir`` or ``binDir``.

``COPY_GRAPH_TO`` specifies an absolute filepath where the generated image will be copied to. The use case for this is to add the generated graph to your source tree, or to documentation, etc.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PROGRAM_DOT

Set to the absolute path of the ``dot`` executable that will be used to generate the graph images for :command:`oranges_add_graphviz_target()`.

.. cmake:variable:: ORANGES_IN_GRAPHVIZ_CONFIG

Set to ``ON`` in the child invocations of CMake launched by :command:`oranges_add_graphviz_target()`. Otherwise, undefined.

.. seealso ::

    Module :external:module:`CMakeGraphVizOptions`
        CMake's built in support for GraphViz graph creation.

#]=======================================================================]

include_guard (GLOBAL)

include (OrangesSetUpCache)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

find_program (
    PROGRAM_DOT dot
    DOC "graphviz dot tool, used to generate dependency graph images by the OrangesGraphviz module")

mark_as_advanced (FORCE PROGRAM_DOT)

#

function (oranges_add_graphviz_target)

    if (ORANGES_IN_GRAPHVIZ_CONFIG)
        return ()
    endif ()

    if (NOT PROGRAM_DOT)
        message (AUTHOR_WARNING "dot cannot be found, dependency graph images cannot be generated")
        return ()
    endif ()

    set (options ALL)
    set (oneValueArgs OUTPUT_DIR TARGET GRAPHVIZ_CONFIG_FILE SOURCE_DIR BINARY_DIR COPY_GRAPH_TO)
    set (multiValueArgs EXTRA_CMAKE_OPTIONS)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ORANGES_ARG_SOURCE_DIR)
        set (ORANGES_ARG_SOURCE_DIR "${CMAKE_SOURCE_DIR}")
    endif ()

    if (NOT ORANGES_ARG_BINARY_DIR)
        set (ORANGES_ARG_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/Graphviz")
    endif ()

    #

    set (graphviz_config_file_out_bin "${ORANGES_ARG_BINARY_DIR}/CMakeGraphVizOptions.cmake")
    set (graphviz_config_file_out_src "${ORANGES_ARG_SOURCE_DIR}/CMakeGraphVizOptions.cmake")

    if (EXISTS "${graphviz_config_file_out_bin}")
        set (oranges_graphviz_config_file "${graphviz_config_file_out_bin}")
    elseif (EXISTS "${graphviz_config_file_out_src}")
        set (oranges_graphviz_config_file "${graphviz_config_file_out_src}")
    endif ()

    if (oranges_graphviz_config_file)
        set (needToGenerate FALSE)
    else ()
        set (needToGenerate TRUE)
    endif ()

    if (needToGenerate)
        if (ORANGES_ARG_GRAPHVIZ_CONFIG_FILE)
            if (NOT IS_ABSOLUTE "${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE}")
                set (ORANGES_ARG_GRAPHVIZ_CONFIG_FILE
                     "${CMAKE_CURRENT_LIST_DIR}/${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE}")

                if (NOT EXISTS "${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE}")
                    message (
                        WARNING
                            "${CMAKE_CURRENT_FUNCTION} - Input Graphviz configuration file ${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE} does not exist! Resorting to the default one."
                        )
                    set (needToGenerate TRUE)
                else ()
                    if (NOT
                        (("${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE}" STREQUAL
                          "${graphviz_config_file_out_bin}")
                         OR ("${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE}" STREQUAL
                             "${graphviz_config_file_out_src}")))

                        file (COPY_FILE "${ORANGES_ARG_GRAPHVIZ_CONFIG_FILE}"
                              "${graphviz_config_file_out_bin}")

                        set (needToGenerate FALSE)

                        set (oranges_graphviz_config_file "${graphviz_config_file_out_bin}")
                    endif ()
                endif ()
            endif ()
        endif ()

        if (needToGenerate)
            if (NOT (EXISTS "${graphviz_config_file_out_bin}" OR EXISTS
                                                                 "${graphviz_config_file_out_src}"))

                message (DEBUG
                         "${CMAKE_CURRENT_FUNCTION} - generating CMakeGraphVizOptions.cmake...")

                configure_file (
                    "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/CMakeGraphVizOptions.cmake"
                    "${graphviz_config_file_out_bin}" @ONLY NEWLINE_STYLE UNIX)

                set (oranges_graphviz_config_file "${graphviz_config_file_out_bin}")
            endif ()
        endif ()
    endif ()

    unset (graphviz_config_file_out_bin)
    unset (graphviz_config_file_out_src)
    unset (needToGenerate)

    if (NOT oranges_graphviz_config_file)
        message (
            AUTHOR_WARNING
                "Internal error in ${CMAKE_CURRENT_FUNCTION} - oranges_graphviz_config_file is not defined!"
            )
    endif ()

    #

    if (NOT ORANGES_ARG_OUTPUT_DIR)
        set (ORANGES_ARG_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    endif ()

    set (oranges_generated_graph "${ORANGES_ARG_OUTPUT_DIR}/deps_graph.png")

    if (NOT ORANGES_ARG_TARGET)
        set (ORANGES_ARG_TARGET "${PROJECT_NAME}DependencyGraph")
    endif ()

    configure_file ("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/generate_deps_graph_image.cmake"
                    generate_deps_graph_image.cmake @ONLY NEWLINE_STYLE UNIX)

    set (graph_image_creation_script "${CMAKE_CURRENT_BINARY_DIR}/generate_deps_graph_image.cmake")

    set (dot_file_output "${ORANGES_ARG_OUTPUT_DIR}/deps_graph.dot")

    if (ORANGES_ARG_ALL)
        set (all_flag ALL)
    else ()
        unset (all_flag)
    endif ()

    if (ORANGES_ARG_EXTRA_CMAKE_OPTIONS)
        list (JOIN ORANGES_ARG_EXTRA_CMAKE_OPTIONS " " extra_cmake_args)
    else ()
        unset (extra_cmake_args)
    endif ()

    # cmake-format: off
    add_custom_target (
        "${ORANGES_ARG_TARGET}" ${all_flag}
        COMMAND "${CMAKE_COMMAND}"
                    -S "${ORANGES_ARG_SOURCE_DIR}"
                    -B "${ORANGES_ARG_BINARY_DIR}"
                    -D ORANGES_IN_GRAPHVIZ_CONFIG=ON
                    -D "FETCHCONTENT_BASE_DIR=${FETCHCONTENT_BASE_DIR}"
                    ${extra_cmake_args}
                    "--graphviz=${dot_file_output}"
                    --no-warn-unused-cli
        DEPENDS "${oranges_graphviz_config_file}"
        BYPRODUCTS "${dot_file_output}"
        VERBATIM USES_TERMINAL
        COMMENT "Running child CMake to generate dependency graph..."
        SOURCES "${oranges_graphviz_config_file}")
    # cmake-format: on

    add_custom_command (
        TARGET "${ORANGES_ARG_TARGET}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -P "${graph_image_creation_script}"
        WORKING_DIRECTORY "${ORANGES_ARG_SOURCE_DIR}"
        DEPENDS "${dot_file_output}"
        COMMENT "Generating dependency graph image..."
        VERBATIM USES_TERMINAL)

    set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                 "${dot_file_output}")

    set_target_properties (
        "${ORANGES_ARG_TARGET}" PROPERTIES FOLDER Utility LABELS Utility XCODE_GENERATE_SCHEME OFF
                                           EchoString "Generating dependency graph...")

    if (ORANGES_ARG_COPY_GRAPH_TO)
        if (NOT IS_ABSOLUTE "${ORANGES_ARG_COPY_GRAPH_TO}")
            message (
                AUTHOR_WARNING
                    "${CMAKE_CURRENT_FUNCTION} - COPY_GRAPH_TO must be an absolute path - got ${ORANGES_ARG_COPY_GRAPH_TO}"
                )

            return ()
        endif ()

        add_custom_command (
            TARGET "${ORANGES_ARG_TARGET}"
            POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${oranges_generated_graph}"
                    "${ORANGES_ARG_COPY_GRAPH_TO}" DEPENDS "${oranges_generated_graph}"
            COMMENT "Copying generated dependency graph image to ${ORANGES_ARG_COPY_GRAPH_TO}..."
            VERBATIM USES_TERMINAL)
    endif ()

endfunction ()
