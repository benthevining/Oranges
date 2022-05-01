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

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Accelerate_FOUND

Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- All
- BNNS
- vImage
- vDSP
- vForce
- BLAS

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Apple::Accelerate

#]=======================================================================]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    Accelerate PROPERTIES
    URL "https://developer.apple.com/documentation/accelerate"
    DESCRIPTION "Apple's optimized high performance libraries")

#

oranges_file_scoped_message_context ("FindMTS-ESP")

set (MTS-ESP_FOUND FALSE)

#

find_package_default_component_list (BNNS vImage vDSP vForce BLAS)

#

find_library (AccelerateLib Accelerate DOC "Accelerate framework path")

if (NOT AccelerateLib)
    find_package_warning_or_error ("Accelerate framework not found")
    return ()
endif ()

add_library (Apple_Accelerate IMPORTED UNKNOWN)

set_target_properties (Apple_Accelerate PROPERTIES IMPORTED_LOCATION
                                                   "${AccelerateLib}")

add_library (Apple::Accelerate ALIAS Apple_Accelerate)

#

# if(NOT TARGET Apple_Accelerate) add_library (Apple_Accelerate INTERFACE)
# endif()

# foreach(lib_name IN LISTS Accelerate_FIND_COMPONENTS) if(NOT TARGET
# Apple_${lib_name}) find_library (lib_${lib_name} ${lib_name} DOC "Apple
# framework ${lib_name}")

# if(NOT lib_${lib_name}) find_package_warning_or_error ("Framework ${lib_name}
# not found") continue() endif()

# add_library (Apple_${lib_name} IMPORTED UNKNOWN)

# set_target_properties (Apple_${lib_name} PROPERTIES IMPORTED_LOCATION
# "${lib_${lib_name}}")

# # target_link_libraries (Apple_${lib_name} INTERFACE "-framework ${lib_name}")

# add_library (Apple::${lib_name} ALIAS Apple_${lib_name})

# target_link_libraries (Apple_Accelerate INTERFACE Apple::${lib_name})

# #install (TARGETS Apple_${lib_name} EXPORT AccelerateTargets) endif()
# endforeach()

if (TARGET Apple_vDSP)
    # fixes a bug present when compiling vDSP with GCC
    target_compile_options (
        Apple_vDSP INTERFACE $<$<CXX_COMPILER_ID:GNU>:-flax-vector-conversions>)
endif ()

if (NOT TARGET Apple::Accelerate)
    add_library (Apple::Accelerate ALIAS Apple_Accelerate)
endif ()

set (MTS-ESP_FOUND TRUE)

install (TARGETS Apple_Accelerate EXPORT AccelerateTargets)

install (EXPORT AccelerateTargets
         DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/Accelerate" NAMESPACE Apple::
         COMPONENT Accelerate)

include (CPackComponent)

cpack_add_component (Accelerate DESCRIPTION "Apple Accelerate library")
