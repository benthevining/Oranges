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

UseFaust
-------------------------

Integrate Faust DSP code into your project.

.. command:: faust_add_generation_command

  ::

    faust_add_generation_command (INPUT_FILE <inputFile>
                                  CLASS_NAME <generatedClassName>
                                 [OUTPUT_FILE <outputFile>])

Adds a command to call the Faust compiler to generate the ``<generatedClassName>`` C++ class in the file ``<outputFile>`` from the ``<inputFile>`` Faust .dsp file.

.. command:: faust_add_library

  ::

    faust_add_library (<targetName>
                       INPUT_FILES <fileNames...>
                       CLASS_NAMES <classNames...>
                      [INSTALL_REL_PATH <relPath>]
                      [INSTALL_COMPONENT <compName>])

Calls :command:`faust_add_generation_command() <faust_add_generation_command>` for each pair of passed ``fileNames`` and ``classNames``, and creates an interface library target that contains all the generated sources.

``<fileNames>`` and ``<classNames>`` must be lists of the same length, with each element in the ``<fileNames>`` list corresponding to the element in the ``<classNames>`` list at the same index.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PROGRAM_FAUST

Path to the Faust compiler executable

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

find_program (PROGRAM_FAUST faust DOC "Faust compiler (used by the Oranges UseFaust module)")

mark_as_advanced (FORCE PROGRAM_FAUST)

#

function (faust_add_generation_command)

    if (NOT PROGRAM_FAUST)
        message (
            WARNING
                "${CMAKE_CURRENT_FUNCTION} - Faust not found, Faust targets cannot be configured")
        return ()
    endif ()

    set (oneValueArgs INPUT_FILE OUTPUT_FILE CLASS_NAME)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG INPUT_FILE CLASS_NAME)

    if (NOT ORANGES_ARG_OUTPUT_FILE)
        set (ORANGES_ARG_OUTPUT_FILE
             "${CMAKE_CURRENT_BINARY_DIR}/Faust/${ORANGES_ARG_CLASS_NAME}.h")
    endif ()

    add_custom_command (
        OUTPUT "${ORANGES_ARG_OUTPUT_FILE}"
        COMMAND
            "${PROGRAM_FAUST}" "${ORANGES_ARG_INPUT_FILE}"
            # -I ${Faust_SOURCE_DIR}/libraries
            -o "${ORANGES_ARG_OUTPUT_FILE}" -cn "${ORANGES_ARG_CLASS_NAME}"
        DEPENDS "${ORANGES_ARG_INPUT_FILE}"
        COMMENT "Generating Faust source files...")

endfunction ()

#

function (faust_add_library)

    if (NOT PROGRAM_FAUST)
        message (
            WARNING
                "${CMAKE_CURRENT_FUNCTION} - Faust not found, Faust targets cannot be configured")
        return ()
    endif ()

    set (TARGET_NAME "${ARGV0}")

    if (TARGET "${TARGET_NAME}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${TARGET_NAME} already exists!")
    endif ()

    set (oneValueArgs TARGET_NAME INSTALL_REL_PATH INSTALL_COMPONENT)
    set (multiValueArgs INPUT_FILES CLASS_NAMES)

    cmake_parse_arguments (PARSE_ARGV 1 ORANGES_ARG "" "${oneValueArgs}" "${multiValueArgs}")

    lemons_require_function_arguments (ORANGES_ARG INPUT_FILES CLASS_NAMES)

    list (LENGTH "${ORANGES_ARG_INPUT_FILES}" numInputFiles)
    list (LENGTH "${ORANGES_ARG_CLASS_NAMES}" numClassNames)

    if (NOT "${numInputFiles}" EQUAL "${numClassNames}")
        message (
            FATAL_ERROR
                "${CMAKE_CURRENT_FUNCTION} - the number of INPUT_FILES specified must match the number of CLASS_NAMES specified!"
            )
    endif ()

    if (ORANGES_ARG_INSTALL_REL_PATH)
        set (install_dir "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_INSTALL_REL_PATH}")
    else ()
        set (install_dir "${CMAKE_INSTALL_INCLUDEDIR}")
    endif ()

    if (NOT ORANGES_ARG_INSTALL_COMPONENT)
        set (ORANGES_ARG_INSTALL_COMPONENT faust_generated)
    endif ()

    add_library ("${TARGET_NAME}" INTERFACE)

    set (generated_dir "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/Faust")

    target_include_directories ("${TARGET_NAME}" INTERFACE $<BUILD_INTERFACE:${generated_dir}>
                                                           $<INSTALL_INTERFACE:${install_dir}>)

    # target_include_directories(${target} PRIVATE ${Faust_SOURCE_DIR}/architecture)

    foreach (idx RANGE numInputFiles)

        list (GET "${ORANGES_ARG_INPUT_FILES}" "${idx}" input_file)
        list (GET "${ORANGES_ARG_CLASS_NAMES}" "${idx}" class_name)

        set (generated_file "${generated_dir}/${class_name}.h")

        faust_add_generation_command (INPUT_FILE "${input_file}" CLASS_NAME "${class_name}"
                                      OUTPUT_FILE "${generated_file}")

        target_sources (
            "${TARGET_NAME}" INTERFACE $<BUILD_INTERFACE:${generated_file}>
                                       $<INSTALL_INTERFACE:${install_dir}/${class_name}.h>)

        install (FILES "${generated_file}" DESTINATION "${install_dir}"
                 COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")

    endforeach ()

endfunction ()
