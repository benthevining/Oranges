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

OrangesAllIntegrations
-------------------------

Searches for ccache and all static analysis integration programs and enables the ones that are available.

This module searches for the following packages:

- ccache
- clang-tidy
- cppcheck
- cpplint
- include-what-you-use

and enables build-time integrations for any of the tools that are found. No errors are emitted for unfound integration tools.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesAllIntegrations``

.. seealso ::

    Module :module:`Findccache`
        Find module for ccache

    Module :module:`Findclang-tidy`
        Find module for clang-tidy

    Module :module:`Findcppcheck`
        Find module for cppcheck

    Module :module:`Findcpplint`
        Find module for cpplint

    Module :module:`Findinclude-what-you-use`
        Find module for include-what-you-use

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesAllIntegrations)
    return ()
endif ()

include (OrangesCmakeDevTools)
include (FeatureSummary)

oranges_file_scoped_message_context ("OrangesAllIntegrations")

find_package (ccache MODULE QUIET)
find_package (clang-tidy MODULE QUIET)
find_package (cppcheck MODULE QUIET)
find_package (cpplint MODULE QUIET)
find_package (include-what-you-use MODULE QUIET)

add_library (OrangesAllIntegrations INTERFACE)

target_link_libraries (
    OrangesAllIntegrations
    INTERFACE $<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:ccache::ccache-interface>>
              $<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:Clang::clang-tidy-interface>>
              $<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:cppcheck::cppcheck-interface>>
              $<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:Google::cpplint-interface>>
              $<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:Google::include-what-you-use-interface>>)

install (TARGETS OrangesAllIntegrations EXPORT OrangesTargets)

add_library (Oranges::OrangesAllIntegrations ALIAS OrangesAllIntegrations)
