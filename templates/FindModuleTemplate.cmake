#[=======================================================================[.rst:

Find<__package_name>
-------------------------

A find module for <__package_name> itself.

This file can be copied verbatim into any projects that depend on <__package_name>, and committed to their source control -- this is what I do for my projects.

You can then use the environment or command line variable :variable:`<__upper_package_name>_PATH` to turn this find module into an :external:command:`add_subdirectory() <add_subdirectory>` of a local copy of <__package_name>;
if neither variable is set, this module will use :external:module:`FetchContent` to download the <__package_name> sources from GitHub.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: <__upper_package_name>_PATH

This variable may be set to a local copy of the <__package_name> repository, in which case calling ``find_package (<__package_name>)`` will result in this script executing ``add_subdirectory (${<__upper_package_name>_PATH})``.

If this variable is not set, this script will use CMake's :external:module:`FetchContent` module to fetch the <__package_name> sources using Git.

This variable is initialized by the value of the :envvar:`<__upper_package_name>_PATH` environment variable.

Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: <__upper_package_name>_PATH

Initializes the :variable:`<__upper_package_name>_PATH` variable.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

include (FindPackageMessage)
include (FeatureSummary)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "<__package_repo_url>"
    DESCRIPTION "<__package_description>")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

if (NOT (DEFINED <__upper_package_name>_PATH OR DEFINED CACHE{<__upper_package_name>_PATH}))
    if (DEFINED ENV{<__upper_package_name>_PATH})
        set (<__upper_package_name>_PATH "$ENV{<__upper_package_name>_PATH}" CACHE PATH "Path to the <__package_name> repository")
    endif ()
endif ()

#

include (FindPackageHandleStandardArgs)

# cmake-lint: disable=C0103
macro(__find_<__package_name>_check_version_from_cmakelists __cmakelists_path __result_var)

    if (NOT EXISTS "${__cmakelists_path}")
        message (WARNING "CMakeLists.txt does not exist at path ${__cmakelists_path}!")
        set (${__result_var} TRUE)
        return ()
    endif ()

    file (READ "${pkg_cmakelists}" __cmakelists_text)

    string (FIND "${__cmakelists_text}" "project (" __project_cmd_pos)

    string (SUBSTRING "${__cmakelists_text}" "${__project_cmd_pos}" 50 __project_cmd_string)

    string (FIND "${__project_cmd_string}" "VERSION" __version_kwd_pos)

    math (EXPR __version_kwd_pos "${__version_kwd_pos} + 8" OUTPUT_FORMAT DECIMAL)

    string (SUBSTRING "${__project_cmd_string}" "${__version_kwd_pos}" 6 __project_version_string)

    find_package_check_version ("${__project_version_string}" "${__result_var}"
                                HANDLE_VERSION_RANGE)
endmacro()

#

# cmake-lint: disable=C0103
function (__find_<__package_name>_try_local_dir)
    if (NOT IS_DIRECTORY "${<__upper_package_name>_PATH}")
        message (WARNING "<__upper_package_name>_PATH set to non-existent directory ${<__upper_package_name>_PATH}!")
        return ()
    endif ()

    __find_<__package_name>_check_version_from_cmakelists ("${<__upper_package_name>_PATH}/CMakeLists.txt" local_copy_found)

    if (NOT local_copy_found)
        message (WARNING "Local copy of <__package_name> has an unsuitable version, falling back to fetching the sources with git...")
        return()
    endif()

    add_subdirectory ("${<__upper_package_name>_PATH}" "${CMAKE_BINARY_DIR}/<__package_name>")

    find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "<__package_name> package found -- local"
                          "<__package_name> (local)[${<__upper_package_name>_PATH}]")

    set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE PARENT_SCOPE)
endfunction ()

#

if (<__upper_package_name>_PATH)
    __find_<__package_name>_try_local_dir ()
endif ()

if (${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

#

set (FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/Cache" CACHE PATH "FetchContent dependency cache")

mark_as_advanced (FETCHCONTENT_BASE_DIR)

include (FetchContent)

FetchContent_Declare (<__package_name> GIT_REPOSITORY "<__package_git_repo>"
                      GIT_TAG "<__package_git_tag>")

FetchContent_MakeAvailable (<__package_name>)

__find_<__package_name>_check_version_from_cmakelists ("${<__lower_package_name>_SOURCE_DIR}/CMakeLists.txt" fetched_copy_works)

if(NOT fetched_copy_works)
    message(WARNING "Fetched copy of <__package_name> has an unsuitable version!")
    return()
endif()

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "<__package_name> package found -- Sources downloaded"
                      "<__package_name> (git)")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
