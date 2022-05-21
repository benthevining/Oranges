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

OrangesStaticAnalysis
-------------------------

Searches for all static analysis integration tools and enables the ones that are available.

This module searches for the following programs:

- :module:`clang-tidy <OrangesClangTidy>`
- :module:`cppcheck <OrangesCppcheck>`
- :module:`cpplint <OrangesCpplint>`
- :module:`include-what-you-use <OrangesIWYU>`

and enables build-time integrations for any of the tools that are found. No errors are emitted for unfound integration tools.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``Oranges::OrangesStaticAnalysis``

Interface target that links to all the static analysis tools' interface targets.

.. seealso ::

    Module :module:`OrangesClangTidy`
        Module for clang-tidy

    Module :module:`OrangesCppcheck`
        Module for cppcheck

    Module :module:`OrangesCpplint`
        Module for cpplint

    Module :module:`OrangesIWYU`
        Module for include-what-you-use

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesStaticAnalysis)
    return ()
endif ()

include (FeatureSummary)
include (OrangesClangTidy)
include (OrangesCppcheck)
include (OrangesCpplint)
include (OrangesIWYU)

add_library (OrangesStaticAnalysis INTERFACE)

target_link_libraries (
    OrangesStaticAnalysis
    INTERFACE "$<BUILD_INTERFACE:ClangTidy::interface>" "$<BUILD_INTERFACE:cppcheck::interface>"
              "$<BUILD_INTERFACE:cpplint::interface>" "$<BUILD_INTERFACE:IWYU::interface>")

install (TARGETS OrangesStaticAnalysis EXPORT OrangesTargets)

add_library (Oranges::OrangesStaticAnalysis ALIAS OrangesStaticAnalysis)
