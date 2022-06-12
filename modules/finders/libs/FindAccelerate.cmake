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

FindAccelerate
-------------------------

A find module for Apple's Accelerate libraries.

Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- All
- BNNS
- vImage
- vDSP
- vForce
- BLAS

Each one creates a target named ``Accelerate::<Component>``.
Each one's path can be set using the cache variable ``ACCELERATE_<Component>_PATH``.

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Accelerate::Accelerate

#]=======================================================================]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES
    URL "https://developer.apple.com/documentation/accelerate"
    DESCRIPTION "Apple's optimized high performance libraries")

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

find_package_default_component_list (BNNS vImage vDSP vForce BLAS)

#

foreach (comp_name IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (TARGET Accelerate::${comp_name})
        continue ()
    endif ()

    if (IOS OR "${CMAKE_SYSTEM_NAME}" MATCHES iOS)
        add_library (Accelerate::${comp_name} IMPORTED INTERFACE)

        target_link_libraries (Accelerate::${comp_name} INTERFACE -framework "${comp_name}")
    else ()
        find_library (ACCELERATE_${comp_name}_PATH "${comp_name}"
                      DOC "Accelerate ${comp_name} library")

        if (ACCELERATE_${comp_name}_PATH)
            add_library (Accelerate::${comp_name} IMPORTED UNKNOWN)

            set_target_properties (Accelerate::${comp_name}
                                   PROPERTIES IMPORTED_LOCATION "ACCELERATE_${${comp_name}_PATH}")
        endif ()
    endif ()

    if (NOT TARGET Accelerate::${comp_name})
        set (${CMAKE_FIND_PACKAGE_NAME}_${comp_name}_FOUND FALSE)
        continue ()
    endif ()

    list (APPEND found_components "${comp_name}")

    set (${CMAKE_FIND_PACKAGE_NAME}_${comp_name}_FOUND TRUE)

    if ("${comp_name}" STREQUAL vDSP)
        # fixes a bug present when compiling vDSP with GCC
        target_compile_options (Accelerate::${comp_name}
                                INTERFACE $<$<CXX_COMPILER_ID:GNU>:-flax-vector-conversions>)
    endif ()

    if (NOT TARGET Accelerate::Accelerate)
        add_library (Accelerate::Accelerate INTERFACE IMPORTED)
    endif ()

    target_link_libraries (Accelerate::Accelerate INTERFACE Accelerate::${comp_name})
endforeach ()

#

if (NOT TARGET Accelerate::Accelerate)
    return ()
endif ()

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message (
    "${CMAKE_FIND_PACKAGE_NAME}" "Accelerate - found components ${found_components}"
    "Accelerate [${found_components}]")

unset (found_components)
