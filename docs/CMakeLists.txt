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

set (ORANGES_DOCS_BUILD_TREE "${Oranges_BINARY_DIR}/OrangesDocs")

set (configured_script "${CMAKE_CURRENT_BINARY_DIR}/generate_rsts.py")

configure_file (generate_rsts.py "${configured_script}" @ONLY NEWLINE_STYLE UNIX)

file (GLOB scripts_rsts LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_LIST_DIR}"
      CONFIGURE_DEPENDS scripts/*.rst)

file (GLOB rst_files LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_LIST_DIR}" CONFIGURE_DEPENDS
                                                                                 *.rst)

add_custom_command (
    OUTPUT "${ORANGES_DOCS_BUILD_TREE}/index.rst"
    COMMAND Python3::Interpreter "${configured_script}"
    DEPENDS generate_rsts.py process_source_tree.py ${scripts_rsts} ${rst_files}
    COMMENT "Oranges docs: preparing docs build tree..."
    VERBATIM USES_TERMINAL)

unset (scripts_rsts)
unset (rst_files)

set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                                    "${ORANGES_DOCS_BUILD_TREE}")

#

set (conf_path "${CMAKE_CURRENT_LIST_DIR}")
set (scripts_path "${Oranges_SOURCE_DIR}/scripts")
set (conf_version "${Oranges_VERSION_MAJOR}.${Oranges_VERSION_MINOR}.${Oranges_VERSION_PATCH}")

configure_file (conf.py conf.py @ONLY NEWLINE_STYLE UNIX)

unset (conf_path)
unset (conf_version)
unset (scripts_path)

set (docs_output "${Oranges_SOURCE_DIR}/doc")

set (doc_format_outputs "")
set (doc_format_last "")

foreach (format IN ITEMS html singlehtml man)
    set (doc_format_output "doc_format_${format}")

    # cmake-format: off
    add_custom_command (
        OUTPUT "${doc_format_output}"
        COMMAND
            "${SPHINX_EXECUTABLE}"
                -c "${CMAKE_CURRENT_BINARY_DIR}"
                -d "${CMAKE_CURRENT_BINARY_DIR}/doctrees"
                -b "${format}"
                ${sphinx_flags}
                "${ORANGES_DOCS_BUILD_TREE}"
                "${docs_output}/${format}"
        DEPENDS "${ORANGES_DOCS_BUILD_TREE}/index.rst"
                ${doc_format_last}
                colors.py conf.py oranges.css
        COMMENT "Oranges docs - building format ${format}..."
        VERBATIM USES_TERMINAL)
    # cmake-format: on

    set_property (SOURCE "${doc_format_output}" PROPERTY SYMBOLIC 1)
    list (APPEND doc_format_outputs "${doc_format_output}")
    set (doc_format_last "${doc_format_output}")
endforeach ()

unset (doc_format_last)

#

if (Oranges_IS_TOP_LEVEL)
    set (all_flag ALL)
endif ()

add_custom_target (OrangesDocs ${all_flag} DEPENDS "${doc_format_outputs}"
                   COMMENT "Building Oranges documentation...")

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

# TODO: install man pages

install (DIRECTORY "${docs_output}/html" COMPONENT oranges_doc_html
         DESTINATION "${CMAKE_INSTALL_DOCDIR}" PATTERN .buildinfo EXCLUDE)

cpack_add_component (oranges_doc_html DISPLAY_NAME "Oranges HTML docs"
                     DESCRIPTION "Install the Oranges HTML documentation" GROUP oranges_docs)

install (DIRECTORY "${docs_output}/singlehtml" COMPONENT oranges_doc_singlehtml
         DESTINATION "${CMAKE_INSTALL_DOCDIR}" PATTERN .buildinfo EXCLUDE)

cpack_add_component (
    oranges_doc_singlehtml DISPLAY_NAME "Oranges single-page HTML docs"
    DESCRIPTION "Install the Oranges single-page HTML documentation" GROUP oranges_docs)

cpack_add_component_group (
    oranges_docs DISPLAY_NAME "Oranges documentation"
    DESCRIPTION "Install all Oranges documentation" PARENT_GROUP oranges INSTALL_TYPES Developer)
