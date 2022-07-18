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

This module provides the following command:

.. command:: oranges_enable_static_analysis

    ::

        oranges_enable_static_analysis (<target>)

This command searches for the following programs:

- :module:`clang-tidy <OrangesClangTidy>`
- :module:`cppcheck <OrangesCppcheck>`
- :module:`cpplint <OrangesCpplint>`
- :module:`include-what-you-use <OrangesIWYU>`

and enables build-time integrations for any of the tools that are found.
No errors are emitted for unfound tools.


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

include (OrangesClangTidy)
include (OrangesCppcheck)
include (OrangesCpplint)
include (OrangesIWYU)

function (oranges_enable_static_analysis target)

    oranges_enable_clang_tidy ("${target}")
    oranges_enable_cppcheck ("${target}")
    oranges_enable_cpplint ("${target}")
    oranges_enable_iwyu ("${target}")

endfunction ()
