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

if (NOT TARGET Python3::Interpreter)
    message (WARNING "Python3 interpreter not found, Oranges ReadMe target cannot be added")
    return ()
endif ()

if (ORANGES_IN_GRAPHVIZ_CONFIG)
    return ()
endif ()

configure_file ("${CMAKE_CURRENT_LIST_DIR}/update_readme.py"
                "${CMAKE_CURRENT_BINARY_DIR}/update_readme.py" @ONLY NEWLINE_STYLE UNIX)

if (Oranges_IS_TOP_LEVEL)
    set (all_flag ALL)
endif ()

add_custom_target (
    OrangesReadme
    ${all_flag}
    COMMAND Python3::Interpreter "${CMAKE_CURRENT_BINARY_DIR}/update_readme.py"
    COMMENT "Updating Oranges readme..."
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/update_readme.py"
    VERBATIM USES_TERMINAL)

set_property (TARGET OrangesReadme APPEND PROPERTY ADDITIONAL_CLEAN_FILES
                                                   "${CMAKE_CURRENT_BINARY_DIR}/update_readme.py")

set_target_properties (OrangesReadme PROPERTIES FOLDER Utility LABELS "Oranges;Utility"
                                                XCODE_GENERATE_SCHEME OFF)

if (TARGET OrangesDependencyGraph)
    add_dependencies (OrangesReadme OrangesDependencyGraph)
endif ()
