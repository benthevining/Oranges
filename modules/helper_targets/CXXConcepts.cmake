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

CXXConcepts
-------------------------

This module provides a target with any flags necessary to ensure C++20 concepts are available.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::CXXConcepts

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::CXXConcepts)
    return ()
endif ()

add_library (CXXConcepts INTERFACE)

# cmake-format: off
set_target_properties (CXXConcepts PROPERTIES
                        CXX_STANDARD 20
                        CXX_STANDARD_REQUIRED ON)
# cmake-format: on

target_compile_features (CXXConcepts INTERFACE cxx_std_20)

target_compile_options (CXXConcepts INTERFACE $<$<CXX_COMPILER_ID:GNU>:-fconcepts>)

install (TARGETS CXXConcepts EXPORT OrangesTargets)

add_library (Oranges::CXXConcepts ALIAS CXXConcepts)
