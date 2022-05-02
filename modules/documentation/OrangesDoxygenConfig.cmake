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

OrangesDoxygenConfig
-------------------------

This module provides the function :command:`oranges_create_doxygen_target()`.

.. command:: oranges_create_doxygen_target

  ::

    oranges_create_doxygen_target (INPUT_PATHS <inputPaths...>
                                  [TARGET <docsTargetName>]
                                  [OUTPUT_DIR <docsOutputDir>]
                                  [MAIN_PAGE_MD_FILE <mainPageFile>]
                                  [LOGO <logoFile>]
                                  [FILE_PATTERNS <filePatterns...>]
                                  [IMAGE_PATHS <imagePaths...>]
                                  [NO_VERSION_DISPLAY]
                                  [NO_INSTALL] | [INSTALL_COMPONENT <componentName>])

Creates a target to execute Doxygen.

The only required argument is the ``INPUT_PATHS``.
``TARGET`` defaults to ``${PROJECT_NAME}Doxygen``.
``OUTPUT_DIR`` defaults to ``${PROJECT_SOURCE_DIR}/doc``.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("OrangesDoxygenConfig")

#

find_package (Doxygen OPTIONAL_COMPONENTS dot)

if (NOT TARGET Doxygen::doxygen)
    message (WARNING "Doxygen dependencies missing!")

    function (oranges_create_doxygen_target)

    endfunction ()

    return ()
endif ()

#

function (oranges_create_doxygen_target)

    oranges_add_function_message_context ()

    set (options NO_VERSION_DISPLAY NO_INSTALL)
    set (oneValueArgs TARGET MAIN_PAGE_MD_FILE LOGO OUTPUT_DIR INSTALL_COMPONENT)
    set (multiValueArgs INPUT_PATHS FILE_PATTERNS IMAGE_PATHS)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG INPUT_PATHS)
    lemons_check_for_unparsed_args (ORANGES_ARG)

    if (ORANGES_ARG_NO_INSTALL AND ORANGES_ARG_INSTALL_COMPONENT)
        message (
            WARNING
                "Arguments NO_INSTALL and INSTALL_COMPONENT cannot both be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
            )
    endif ()

    foreach (input_path IN LISTS ORANGES_ARG_INPUT_PATHS)
        if (NOT IS_ABSOLUTE)
            set (input_path "${PROJECT_SOURCE_DIR}/${input_path}")
        endif ()

        list (APPEND ORANGES_DOXYGEN_INPUT_PATHS "${input_path}")
    endforeach ()

    list (REMOVE_DUPLICATES ORANGES_DOXYGEN_INPUT_PATHS)
    list (JOIN ORANGES_DOXYGEN_INPUT_PATHS " " ORANGES_DOXYGEN_INPUT_PATHS)

    if (ORANGES_ARG_MAIN_PAGE_MD_FILE)
        if (NOT IS_ABSOLUTE "${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
            set (ORANGES_ARG_MAIN_PAGE_MD_FILE
                 "${PROJECT_SOURCE_DIR}/${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
        endif ()

        if (EXISTS "${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
            set (ORANGES_DOXYGEN_MAIN_PAGE_MARKDOWN_FILE "${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
        else ()
            message (
                AUTHOR_WARNING
                    "Specified Doxygen main page markdown file ${ORANGES_ARG_MAIN_PAGE_MD_FILE} does not exist!"
                )
        endif ()
    else ()
        find_file (
            ORANGES_DOCS_README README.md README PATHS "${PROJECT_SOURCE_DIR}"
                                                       ${ORANGES_DOXYGEN_INPUT_PATHS} NO_CACHE
            NO_DEFAULT_PATH DOC "Readme file for Doxygen documentation")

        if (ORANGES_DOCS_README)
            set (ORANGES_ARG_MAIN_PAGE_MD_FILE "${ORANGES_DOCS_README}")
        endif ()
    endif ()

    if (ORANGES_ARG_MAIN_PAGE_MD_FILE)
        set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
                      PROPERTY CMAKE_CONFIGURE_DEPENDS "${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
    endif ()

    if (ORANGES_ARG_LOGO)
        if (NOT IS_ABSOLUTE "${ORANGES_ARG_LOGO}")
            set (ORANGES_ARG_LOGO "${PROJECT_SOURCE_DIR}/${ORANGES_ARG_LOGO}")
        endif ()

        if (EXISTS "${ORANGES_ARG_LOGO}")
            set (ORANGES_DOXYGEN_LOGO "${ORANGES_ARG_LOGO}")

            set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
                          PROPERTY CMAKE_CONFIGURE_DEPENDS "${ORANGES_ARG_LOGO}")
        else ()
            message (
                AUTHOR_WARNING "Specified Doxygen logo file ${ORANGES_DOXYGEN_LOGO} does not exist!"
                )
        endif ()
    endif ()

    if (NOT ORANGES_ARG_FILE_PATTERNS)
        set (ORANGES_DOXYGEN_INPUT_FILE_PATTERNS "*.h")
    endif ()

    if (ORANGES_ARG_MAIN_PAGE_MD_FILE)
        list (APPEND ORANGES_ARG_FILE_PATTERNS *.md)
    endif ()

    if (ORANGES_ARG_OUTPUT_DIR)
        if (NOT IS_ABSOLUTE "${ORANGES_ARG_OUTPUT_DIR}")
            set (ORANGES_ARG_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/${ORANGES_ARG_OUTPUT_DIR}")
        endif ()
    else ()
        set (ORANGES_DOC_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/doc")
    endif ()

    set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                        "${ORANGES_DOC_OUTPUT_DIR}")

    if (TARGET DependencyGraph)
        list (APPEND ORANGES_ARG_IMAGE_PATHS "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.png")
        list (APPEND ORANGES_ARG_FILE_PATTERNS *.png)
    endif ()

    list (REMOVE_DUPLICATES ORANGES_ARG_IMAGE_PATHS)
    list (REMOVE_DUPLICATES ORANGES_ARG_FILE_PATTERNS)

    list (JOIN ORANGES_ARG_IMAGE_PATHS " " ORANGES_DOXYGEN_INPUT_IMAGE_PATHS)
    list (JOIN ORANGES_ARG_FILE_PATTERNS " " ORANGES_DOXYGEN_INPUT_FILE_PATTERNS)

    set (doxyfile_input "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/Doxyfile")
    set (doxylayout_input "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/DoxygenLayout.xml")

    set (doxyfile_output "${CMAKE_BINARY_DIR}/Doxyfile")
    set (doxylayout_output "${CMAKE_BINARY_DIR}/DoxygenLayout.xml")

    configure_file ("${doxyfile_input}" "${doxyfile_output}" @ONLY)
    configure_file ("${doxylayout_input}" "${doxylayout_output}" @ONLY)

    if (NOT ORANGES_ARG_TARGET)
        set (ORANGES_ARG_TARGET "${PROJECT_NAME}Doxygen")
    endif ()

    add_custom_target (
        "${ORANGES_ARG_TARGET}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${ORANGES_DOC_OUTPUT_DIR}"
        COMMAND Doxygen::doxygen "${doxyfile_output}"
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        VERBATIM
        DEPENDS "${doxyfile_input}" "${doxyfile_output}" "${doxylayout_input}"
                "${doxylayout_output}"
        BYPRODUCTS "${ORANGES_DOC_OUTPUT_DIR}/html/index.html"
        COMMENT "Building ${PROJECT_NAME} documentation...")

    set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND
                  PROPERTY CMAKE_CONFIGURE_DEPENDS "${doxyfile_input}" "${doxylayout_input}")

    set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND
                  PROPERTY ADDITIONAL_CLEAN_FILES "${doxyfile_output}" "${doxylayout_output}")

    if (NOT ORANGES_ARG_NO_VERSION_DISPLAY)
        add_custom_command (
            TARGET "${ORANGES_ARG_TARGET}" PRE_BUILD COMMAND Doxygen::doxygen --version
            COMMENT "Doxygen version:")
    endif ()

    if (TARGET DependencyGraph)
        add_dependencies ("${ORANGES_ARG_TARGET}" DependencyGraph)
    endif ()

    set_property (TARGET "${ORANGES_ARG_TARGET}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                 "${ORANGES_DOC_OUTPUT_DIR}")

    set_target_properties (
        "${ORANGES_ARG_TARGET}"
        PROPERTIES FOLDER Utility LABELS "${PROJECT_NAME};Utility" XCODE_GENERATE_SCHEME OFF
                   EchoString "Building ${PROJECT_NAME} documentation...")

    if (ORANGES_ARG_NO_INSTALL)
        return ()
    endif ()

    if (NOT ORANGES_ARG_INSTALL_COMPONENT)
        set (ORANGES_ARG_INSTALL_COMPONENT "${PROJECT_NAME}_Documentation")
    endif ()

    install (
        DIRECTORY "${ORANGES_DOC_OUTPUT_DIR}/man3"
        TYPE MAN
        COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}"
        EXCLUDE_FROM_ALL OPTIONAL
        PATTERN .DS_Store EXCLUDE)

    install (
        DIRECTORY "${ORANGES_DOC_OUTPUT_DIR}/html"
        TYPE INFO
        COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}"
        EXCLUDE_FROM_ALL OPTIONAL
        PATTERN .DS_Store EXCLUDE)

    install (FILES "${ORANGES_DOC_OUTPUT_DIR}/${PROJECT_NAME}.tag" TYPE INFO OPTIONAL
             COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")

endfunction ()
