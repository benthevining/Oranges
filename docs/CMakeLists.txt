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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (ORANGES_IN_GRAPHVIZ_CONFIG)
    return ()
endif ()

project (
    OrangesDocs
    VERSION "${Oranges_VERSION}"
    DESCRIPTION "Oranges documentation"
    HOMEPAGE_URL "${Oranges_HOMEPAGE_URL}"
    LANGUAGES NONE)

#

find_program (SPHINX_EXECUTABLE NAMES sphinx-build
              DOC "Sphinx Documentation Builder (sphinx-doc.org)")

find_program (MAKEINFO_EXECUTABLE NAMES makeinfo DOC "makeinfo tool")

#[[
Note: on my Mac, the following commands were needed to get the Latex build working:

brew install basictex
sudo tlmgr install latexmk tex-gyre fncychap wrapfig capt-of framed needspace varwidth titlesec
]]

find_program (LATEX_EXECUTABLE NAMES pdflatex DOC "pdflatex tool")

find_program (LATEXMK_EXECUTABLE NAMES latexmk DOC "latexmk tool")

set (ORANGES_SPHINX_FLAGS "" CACHE STRING "Flags to pass to sphinx-build")

mark_as_advanced (ORANGES_SPHINX_FLAGS)

separate_arguments (sphinx_flags UNIX_COMMAND "${ORANGES_SPHINX_FLAGS}")

if (NOT SPHINX_EXECUTABLE)
    if (Oranges_IS_TOP_LEVEL)
        message (
            WARNING "SPHINX_EXECUTABLE (sphinx-build) not found, Oranges docs cannot be built.")
    endif ()

    return ()
endif ()

if (NOT TARGET Python3::Interpreter)
    if (Oranges_IS_TOP_LEVEL)
        message (WARNING "Python interpreter cannot be found, Oranges docs cannot be built!")
    endif ()

    return ()
endif ()

#

set (configured_script "${CMAKE_CURRENT_BINARY_DIR}/generate_rsts.py")

configure_file (generate_rsts.py "${configured_script}" @ONLY NEWLINE_STYLE UNIX)

if (READTHEDOCS OR ENV{READTHEDOCS})
    # execute the configure script during config if running under ReadTheDocs, so that RTD can
    # execute only CMake configure and then be ready to build
    execute_process (COMMAND "${Python3_EXECUTABLE}" "${configured_script}")
endif ()

file (GLOB scripts_rsts LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_LIST_DIR}"
      CONFIGURE_DEPENDS scripts/*.rst)

file (GLOB rst_files LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_LIST_DIR}" CONFIGURE_DEPENDS
                                                                                 *.rst)

add_custom_command (
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/index.rst"
    COMMAND Python3::Interpreter "${configured_script}"
    DEPENDS generate_rsts.py process_source_tree.py ${scripts_rsts} ${rst_files}
    COMMENT "Oranges docs: preparing docs build tree..."
    VERBATIM USES_TERMINAL)

unset (scripts_rsts)
unset (rst_files)

#

set (conf_path "${CMAKE_CURRENT_LIST_DIR}")
set (scripts_path "${Oranges_SOURCE_DIR}/scripts")
set (templates_path "${Oranges_SOURCE_DIR}/templates")
set (conf_version "${Oranges_VERSION_MAJOR}.${Oranges_VERSION_MINOR}.${Oranges_VERSION_PATCH}")

configure_file (conf.py conf.py @ONLY NEWLINE_STYLE UNIX)

unset (conf_path)
unset (conf_version)
unset (scripts_path)

set (docs_output "${Oranges_SOURCE_DIR}/doc")
set (logfiles_dir "${CMAKE_CURRENT_BINARY_DIR}/logs")

if (MAKEINFO_EXECUTABLE)
    set (info_flag info)
endif ()

if (LATEX_EXECUTABLE AND LATEXMK_EXECUTABLE)
    set (latex_flag latexpdf)
endif ()

# cmake-format: off
foreach (format IN ITEMS html singlehtml man text linkcheck ${info_flag} ${latex_flag})
# cmake-format: on
    set (doc_format_output "oranges_doc_format_${format}")
    set (format_warnings_file "${logfiles_dir}/${format}")

    if ("${format}" STREQUAL info OR "${format}" STREQUAL latexpdf)
        # cmake-format: off
        add_custom_command (
            OUTPUT "${doc_format_output}"
            COMMAND
                "${SPHINX_EXECUTABLE}"
                    -M "${format}"
                    "${CMAKE_CURRENT_BINARY_DIR}"
                    "${docs_output}/${format}"
                    -c "${CMAKE_CURRENT_BINARY_DIR}"
                    -d "${CMAKE_CURRENT_BINARY_DIR}/doctrees"
                    -w "${format_warnings_file}"
                    ${sphinx_flags}
            DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/index.rst"
                    ${doc_format_last}
                    colors.py conf.py oranges.css
            COMMENT "Oranges docs - building format ${format}..."
            VERBATIM USES_TERMINAL)
        # cmake-format: on
    else ()
        # cmake-format: off
        add_custom_command (
            OUTPUT "${doc_format_output}"
            COMMAND
                "${SPHINX_EXECUTABLE}"
                    -c "${CMAKE_CURRENT_BINARY_DIR}"
                    -d "${CMAKE_CURRENT_BINARY_DIR}/doctrees"
                    -b "${format}"
                    -w "${format_warnings_file}"
                    ${sphinx_flags}
                    "${CMAKE_CURRENT_BINARY_DIR}"
                    "${docs_output}/${format}"
            DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/index.rst"
                    ${doc_format_last}
                    colors.py conf.py oranges.css
            COMMENT "Oranges docs - building format ${format}..."
            VERBATIM USES_TERMINAL)
        # cmake-format: on
    endif ()

    set_property (SOURCE "${doc_format_output}" PROPERTY SYMBOLIC 1)
    list (APPEND doc_format_outputs "${doc_format_output}")
    set (doc_format_last "${doc_format_output}")
endforeach ()

unset (doc_format_last)
unset (info_flag)
unset (latex_flag)

#

if (Oranges_IS_TOP_LEVEL)
    set (all_flag ALL)
endif ()

add_custom_target (OrangesDocs ${all_flag} DEPENDS "${doc_format_outputs}"
                   COMMENT "Building Oranges documentation...")

set_property (TARGET OrangesDocs APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${logfiles_dir}"
                                                 "${docs_output}")

unset (all_flag)

set_target_properties (OrangesDocs PROPERTIES FOLDER Utility LABELS "Oranges;Utility;Documentation"
                                              XCODE_GENERATE_SCHEME OFF)

if (TARGET OrangesReadme)
    add_dependencies (OrangesDocs OrangesReadme)
endif ()

if (TARGET OrangesDependencyGraph)
    add_dependencies (OrangesDocs OrangesDependencyGraph)
endif ()

unset (doc_format_outputs)

#

install (DIRECTORY "${docs_output}/html" COMPONENT oranges_doc_html
         DESTINATION "${CMAKE_INSTALL_DOCDIR}" PATTERN .buildinfo EXCLUDE)

cpack_add_component (oranges_doc_html DISPLAY_NAME "Oranges HTML docs"
                     DESCRIPTION "Install the Oranges HTML documentation" GROUP oranges_docs)

install (DIRECTORY "${docs_output}/singlehtml" COMPONENT oranges_doc_singlehtml
         DESTINATION "${CMAKE_INSTALL_DOCDIR}" PATTERN .buildinfo EXCLUDE)

cpack_add_component (
    oranges_doc_singlehtml DISPLAY_NAME "Oranges single-page HTML docs"
    DESCRIPTION "Install the Oranges single-page HTML documentation" GROUP oranges_docs)

install (FILES "${docs_output}/man/oranges.1" COMPONENT oranges_doc_man
         DESTINATION "${CMAKE_INSTALL_MANDIR}")

cpack_add_component (oranges_doc_man DISPLAY_NAME "Oranges man pages"
                     DESCRIPTION "Install the Oranges man pages" GROUP oranges_docs)

if (MAKEINFO_EXECUTABLE)
    install (FILES "${docs_output}/info/texinfo/oranges.info" COMPONENT oranges_doc_info
             DESTINATION "${CMAKE_INSTALL_INFODIR}")

    cpack_add_component (oranges_doc_info DISPLAY_NAME "Oranges info pages"
                         DESCRIPTION "Install the Oranges info pages" GROUP oranges_docs)
endif ()

if (LATEX_EXECUTABLE AND LATEXMK_EXECUTABLE)
    install (FILES "${docs_output}/latexpdf/latex/oranges.pdf" COMPONENT oranges_doc_pdf
             DESTINATION "${CMAKE_INSTALL_DOCDIR}")

    cpack_add_component (oranges_doc_pdf DISPLAY_NAME "Oranges PDF documentation"
                         DESCRIPTION "Install the Oranges PDF documentation" GROUP oranges_docs)
endif ()

cpack_add_component_group (
    oranges_docs DISPLAY_NAME "Oranges documentation"
    DESCRIPTION "Install all Oranges documentation" PARENT_GROUP oranges INSTALL_TYPES Developer)
