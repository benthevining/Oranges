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

OrangesJuceModuleUtilities
---------------------------

Utilities for adding custom JUCE modules to projects.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFileUtils)
include (OrangesJuceUtilities)
include (OrangesCmakeDevTools)

#

define_property (
    TARGET
    PROPERTY OriginalModuleNames
    INHERITED
    BRIEF_DOCS "Original juce module names"
    FULL_DOCS
        "The original names of a juce module category target's individual juce modules, without the Namespace:: prefixes."
    )

define_property (
    TARGET
    PROPERTY ModuleCategoryNames
    INHERITED
    BRIEF_DOCS "Juce module category names"
    FULL_DOCS
        "The original names of the lemons juce module category targets, without the Lemons:: prefix."
    )

function (lemons_add_juce_modules)

    oranges_add_function_message_context ()

    set (oneValueArgs DIR AGGREGATE ALIAS_NAMESPACE)

    cmake_parse_arguments (LEMONS_MOD "" "${oneValueArgs}" "" ${ARGN})

    lemons_require_function_arguments (LEMONS_MOD DIR)
    lemons_check_for_unparsed_args (LEMONS_MOD)

    if (LEMONS_MOD_AGGREGATE)
        if (NOT TARGET ${LEMONS_MOD_AGGREGATE})
            message (
                DEBUG
                "Adding Juce module aggregate target ${LEMONS_MOD_AGGREGATE}")
            add_library (${LEMONS_MOD_AGGREGATE} INTERFACE)
        endif ()
    endif ()

    lemons_subdir_list (RESULT moduleFolders DIR "${LEMONS_MOD_DIR}")

    foreach (folder ${moduleFolders})
        if (LEMONS_MOD_ALIAS_NAMESPACE)
            juce_add_module ("${LEMONS_MOD_DIR}/${folder}" ALIAS_NAMESPACE
                             ${LEMONS_MOD_ALIAS_NAMESPACE})
        else ()
            juce_add_module ("${LEMONS_MOD_DIR}/${folder}")
        endif ()

        if (LEMONS_MOD_AGGREGATE)
            if (LEMONS_MOD_ALIAS_NAMESPACE)
                target_link_libraries (
                    ${LEMONS_MOD_AGGREGATE}
                    INTERFACE "${LEMONS_MOD_ALIAS_NAMESPACE}::${folder}")
            else ()
                target_link_libraries (${LEMONS_MOD_AGGREGATE}
                                       INTERFACE ${folder})
            endif ()

            set_property (TARGET ${LEMONS_MOD_AGGREGATE} APPEND
                          PROPERTY OriginalModuleNames ${folder})
        endif ()
    endforeach ()

    if (LEMONS_MOD_ALIAS_NAMESPACE AND LEMONS_MOD_AGGREGATE)
        set (aggregateAlias
             "${LEMONS_MOD_ALIAS_NAMESPACE}::${LEMONS_MOD_AGGREGATE}")

        if (NOT TARGET ${aggregateAlias})
            add_library (${aggregateAlias} ALIAS ${LEMONS_MOD_AGGREGATE})
        endif ()
    endif ()
endfunction ()

#

function (_lemons_add_module_subcategory)

    oranges_add_function_message_context ()

    cmake_parse_arguments (LEMONS_SUBMOD "" "TARGET" "CATEGORY_DEPS" ${ARGN})

    lemons_require_function_arguments (LEMONS_SUBMOD TARGET)
    lemons_check_for_unparsed_args (LEMONS_SUBMOD)

    lemons_add_juce_modules (DIR "${CMAKE_CURRENT_LIST_DIR}" AGGREGATE
                             ${LEMONS_SUBMOD_TARGET} ALIAS_NAMESPACE Lemons)

    if (NOT TARGET AllLemonsModules)
        add_library (AllLemonsModules INTERFACE)
    endif ()

    target_link_libraries (AllLemonsModules
                           INTERFACE Lemons::${LEMONS_SUBMOD_TARGET})

    set_property (TARGET AllLemonsModules APPEND
                  PROPERTY ModuleCategoryNames ${LEMONS_SUBMOD_TARGET})

    foreach (categoryDependency ${LEMONS_SUBMOD_CATEGORY_DEPS})

        include (${categoryDependency})

        target_link_libraries (${LEMONS_SUBMOD_TARGET}
                               INTERFACE Lemons::${categoryDependency})
    endforeach ()
endfunction ()
