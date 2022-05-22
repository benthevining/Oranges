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

OrangesSphinx
-------------------------

This module provides the function :command:`oranges_add_sphinx_docs()`.

.. command:: oranges_add_sphinx_docs

  ::

    oranges_add_sphinx_docs (DOC_TREE <dir>
                            [PROJECT_NAME <project>] [VERSION <version>]
                            [TARGET <targetName>] [ALL] [COMMENT <buildComment...>]
                            [CONF_FILE <yourConf.py>]
                            [FORMATS <formats...>]
                            [HTML_THEME <themeName>]
                            [EXTRA_FLAGS <sphinxFlags...>]
                            [OUTPUT_DIR <directory>]
                            [NO_INSTALL] | [INSTALL_COMPONENT_BASE_NAME <baseName>] [INSTALL_COMPONENT_GROUP <groupName>] [INSTALL_COMPONENT_GROUP_PARENT <parentGroup>])



#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)
include (GNUInstallDirs)
include (CPackComponent)

find_program (SPHINX_EXECUTABLE NAMES sphinx-build
              DOC "Sphinx Documentation Builder (sphinx-doc.org)")

find_program (MAKEINFO_EXECUTABLE NAMES makeinfo DOC "makeinfo tool")

find_program (LATEX_EXECUTABLE NAMES pdflatex DOC "pdflatex tool")

find_program (LATEXMK_EXECUTABLE NAMES latexmk DOC "latexmk tool")

#

function (oranges_add_sphinx_docs)

    if (ORANGES_IN_GRAPHVIZ_CONFIG)
        return ()
    endif ()

    if (NOT SPHINX_EXECUTABLE)
        message (WARNING "Sphinx not found, Sphinx docs cannot be configured!")
        return ()
    endif ()

    set (options ALL NO_INSTALL)
    set (
        oneValueArgs
        DOC_TREE
        PROJECT_NAME
        CONF_FILE
        OUTPUT_DIR
        TARGET
        COMMENT
        INSTALL_COMPONENT_BASE_NAME
        INSTALL_COMPONENT_GROUP
        INSTALL_COMPONENT_GROUP_PARENT
        HTML_THEME
        VERSION)
    set (multiValueArgs FORMATS EXTRA_FLAGS)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    lemons_require_function_arguments (ORANGES_ARG DOC_TREE)

    if (NOT ORANGES_ARG_PROJECT_NAME)
        set (ORANGES_ARG_PROJECT_NAME "${PROJECT_NAME}")
    endif ()

    if (NOT ORANGES_ARG_TARGET)
        set (ORANGES_ARG_TARGET "${ORANGES_ARG_PROJECT_NAME}Docs")
    endif ()

    if (ORANGES_ARG_CONF_FILE)
        cmake_path (GET ORANGES_ARG_CONF_FILE PARENT_PATH conf_file_dir)
    else ()
        if (NOT ORANGES_ARG_HTML_THEME)
            set (ORANGES_ARG_HTML_THEME alabaster)
        endif ()

        if (NOT ORANGES_ARG_VERSION)
            if (${ORANGES_ARG_PROJECT_NAME}_VERSION)
                set (ORANGES_ARG_VERSION "${${ORANGES_ARG_PROJECT_NAME}_VERSION}")
            else ()
                set (ORANGES_ARG_VERSION "${PROJECT_VERSION}")
            endif ()
        endif ()

        configure_file ("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/conf.py" conf.py @ONLY
                        NEWLINE_STYLE UNIX)

        set (conf_file_dir "${CMAKE_CURRENT_BINARY_DIR}")
    endif ()

    if (ORANGES_ARG_FORMATS)
        set (
            validFormats
            html
            dirhtml
            singlehtml
            htmlhelp
            qthelp
            devhelp
            epub
            latex
            man
            texinfo
            text
            gettext
            doctest
            linkcheck
            xml
            pseudoxml)

        if (APPLE)
            list (APPEND validFormats applehelp)
        endif ()

        if (MAKEINFO_EXECUTABLE)
            list (APPEND validFormats info)
        endif ()

        if (LATEX_EXECUTABLE AND LATEXMK_EXECUTABLE)
            list (APPEND validFormats latexpdf)
        endif ()

        foreach (format IN LISTS ORANGES_ARG_FORMATS)
            if ("${format}" IN_LIST validFormats)
                list (APPEND building_formats "${format}")
            else ()
                message (
                    WARNING
                        "${CMAKE_CURRENT_FUNCTION} - unknown or unsupported Sphinx format requested: ${format}"
                    )
            endif ()
        endforeach ()
    else ()
        set (building_formats html singlehtml man linkcheck)

        if (MAKEINFO_EXECUTABLE)
            list (APPEND building_formats info)
        endif ()

        if (LATEX_EXECUTABLE AND LATEXMK_EXECUTABLE)
            list (APPEND building_formats latexpdf)
        endif ()
    endif ()

    if (NOT ORANGES_ARG_OUTPUT_DIR)
        set (ORANGES_ARG_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/doc")
    endif ()

    separate_arguments (sphinx_flags UNIX_COMMAND "${ORANGES_ARG_EXTRA_FLAGS}")

    set (logfiles_dir "${CMAKE_CURRENT_BINARY_DIR}/logs")

    foreach (format IN LISTS building_formats)
        set (doc_format_output "${ORANGES_ARG_PROJECT_NAME}_doc_format_${format}")
        set (format_warnings_file "${logfiles_dir}/${format}")

        if ("${format}" STREQUAL info OR "${format}" STREQUAL latexpdf)
            # cmake-format: off
            add_custom_command (
                OUTPUT "${doc_format_output}"
                COMMAND
                    "${SPHINX_EXECUTABLE}"
                        -M "${format}"
                        "${ORANGES_ARG_DOC_TREE}"
                        "${ORANGES_ARG_OUTPUT_DIR}/${format}"
                        -c "${conf_file_dir}"
                        -d "${CMAKE_CURRENT_BINARY_DIR}/doctrees"
                        -w "${format_warnings_file}"
                        ${sphinx_flags}
                DEPENDS ${doc_format_last}
                COMMENT "${ORANGES_ARG_PROJECT_NAME} docs - building format ${format}..."
                VERBATIM USES_TERMINAL)
            # cmake-format: on
        else ()
            # cmake-format: off
            add_custom_command (
                OUTPUT "${doc_format_output}"
                COMMAND
                    "${SPHINX_EXECUTABLE}"
                        -c "${conf_file_dir}"
                        -d "${CMAKE_CURRENT_BINARY_DIR}/doctrees"
                        -b "${format}"
                        -w "${format_warnings_file}"
                        ${sphinx_flags}
                        "${ORANGES_ARG_DOC_TREE}"
                        "${ORANGES_ARG_OUTPUT_DIR}/${format}"
                DEPENDS ${doc_format_last}
                COMMENT "${ORANGES_ARG_PROJECT_NAME} docs - building format ${format}..."
                VERBATIM USES_TERMINAL)
            # cmake-format: on
        endif ()

        set_source_files_properties ("${doc_format_output}" PROPERTIES SYMBOLIC 1)

        # set_property (SOURCE "${doc_format_output}" PROPERTY SYMBOLIC 1)
        list (APPEND doc_format_outputs "${doc_format_output}")
        set (doc_format_last "${doc_format_output}")
    endforeach ()

    if (ORANGES_ARG_ALL)
        set (all_flag ALL)
    endif ()

    if (NOT ORANGES_ARG_COMMENT)
        set (ORANGES_ARG_COMMENT "Building ${ORANGES_ARG_PROJECT_NAME} documentation...")
    endif ()

    add_custom_target ("${ORANGES_ARG_TARGET}" ${all_flag} DEPENDS "${doc_format_outputs}"
                       COMMENT "${ORANGES_ARG_COMMENT}")

    set_property (
        TARGET "${ORANGES_ARG_TARGET}" APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES "${logfiles_dir}" "${ORANGES_DOCS_BUILD_TREE}"
                 "${ORANGES_ARG_OUTPUT_DIR}")

    if (ORANGES_ARG_NO_INSTALL)
        if (ORANGES_ARG_INSTALL_COMPONENT_GROUP OR ORANGES_ARG_INSTALL_COMPONENT_BASE_NAME
            OR ORANGES_ARG_INSTALL_COMPONENT_GROUP_PARENT)
            message (
                AUTHOR_WARNING
                    "${CMAKE_CURRENT_FUNCTION} - NO_INSTALL specified along with installation configuration options!"
                )
        endif ()

        return ()
    endif ()

    if (ORANGES_ARG_INSTALL_COMPONENT_GROUP)
        set (group_flag GROUP "${ORANGES_ARG_INSTALL_COMPONENT_GROUP}")
    endif ()

    string (TOLOWER "${ORANGES_ARG_PROJECT_NAME}" lower_proj_name)

    if (NOT ORANGES_ARG_INSTALL_COMPONENT_BASE_NAME)
        set (ORANGES_ARG_INSTALL_COMPONENT_BASE_NAME "${lower_proj_name}_doc")
    endif ()

    foreach (format IN LISTS building_formats)
        set (component_name "${ORANGES_ARG_INSTALL_COMPONENT_BASE_NAME}_${format}")

        if ("${format}" STREQUAL latexpdf)
            install (FILES "${ORANGES_ARG_OUTPUT_DIR}/latexpdf/latex/${lower_proj_name}.pdf"
                     COMPONENT "${component_name}" DESTINATION "${CMAKE_INSTALL_DOCDIR}")

            cpack_add_component (
                "${component_name}" DISPLAY_NAME "${ORANGES_ARG_PROJECT_NAME} PDF documentation"
                DESCRIPTION "Install the ${ORANGES_ARG_PROJECT_NAME} PDF documentation"
                            ${group_flag})

            continue ()
        endif ()

        if ("${format}" STREQUAL info)
            install (FILES "${ORANGES_ARG_OUTPUT_DIR}/info/texinfo/${lower_proj_name}.info"
                     COMPONENT "${component_name}" DESTINATION "${CMAKE_INSTALL_INFODIR}")

            cpack_add_component (
                "${component_name}" DISPLAY_NAME "${ORANGES_ARG_PROJECT_NAME} info pages"
                DESCRIPTION "Install the ${ORANGES_ARG_PROJECT_NAME} info pages" ${group_flag})

            continue ()
        endif ()

        if ("${format}" STREQUAL man)
            install (FILES "${ORANGES_ARG_OUTPUT_DIR}/man/${lower_proj_name}.1"
                     COMPONENT "${component_name}" DESTINATION "${CMAKE_INSTALL_MANDIR}")

            cpack_add_component (
                "${component_name}" DISPLAY_NAME "${ORANGES_ARG_PROJECT_NAME} man pages"
                DESCRIPTION "Install the "${ORANGES_ARG_PROJECT_NAME}" man pages" ${group_flag})

            continue ()
        endif ()

        install (DIRECTORY "${ORANGES_ARG_OUTPUT_DIR}/${format}" COMPONENT "${component_name}"
                 DESTINATION "${CMAKE_INSTALL_DOCDIR}" PATTERN .buildinfo EXCLUDE)

        cpack_add_component (
            "${component_name}" DISPLAY_NAME "Oranges ${format} docs"
            DESCRIPTION "Install the ${ORANGES_ARG_OUTPUT_DIR} ${format} documentation"
                        ${group_flag})
    endforeach ()

    if (ORANGES_ARG_INSTALL_COMPONENT_GROUP)
        if (ORANGES_ARG_INSTALL_COMPONENT_GROUP_PARENT)
            set (parent_flag PARENT_GROUP "${ORANGES_ARG_INSTALL_COMPONENT_GROUP_PARENT}")
        endif ()

        cpack_add_component_group (
            "${ORANGES_ARG_INSTALL_COMPONENT_GROUP}"
            DISPLAY_NAME "${ORANGES_ARG_PROJECT_NAME} documentation"
            DESCRIPTION "Install all ${ORANGES_ARG_PROJECT_NAME} documentation"
                        INSTALL_TYPES Developer ${parent_flag})
    endif ()

endfunction ()
