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

FindIPP
-------------------------

A find module for the Intel IPP libraries.

IPP must be manually installed by the developer, it cannot be fetched by a script.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: IPP_ROOT

This can be manually overridden to provide the path to the root of the IPP installation.
This variable will be initialized by the :envvar:`IPP_ROOT` environment variable.


.. cmake:variable:: IPP_INCLUDE_DIR

The path to the include directory for IPP.
This variable will be initialized by the :envvar:`IPP_INCLUDE_DIR` environment variable.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: IPP_ROOT

If set, this environment variable will initialize the :variable:`IPP_ROOT` variable.


.. cmake:envvar:: IPP_INCLUDE_DIR

If set, this environment variable will initialize the :variable:`IPP_INCLUDE_DIR` variable.


Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- All  : Imports all components
- CORE : IPP core library
- AC   : audio coding
- CC   : color conversion
- CH   : string processing
- CP   : cryptography
- CV   : computer vision
- DC   : data compression
- DI   : data integrity
- GEN  : generated functions
- I    : image processing
- J    : image compression
- R    : rendering and 3D data processing
- M    : small matrix operations
- S    : signal processing
- SC   : speech coding
- SR   : speech recognition
- VC   : video coding
- VM   : vector math

Each one produces an imported target named ``IPP::<Component>``.
Each one's path can be set using the cache variable ``IPP_LIB_<Component>``.

Each component imports its dependencies as well:

.. table:: IPP component dependencies

    +---------------------+--------------+-----------------+
    | Domain              | Domain Code  | Depends On      |
    +=====================+==============+=================+
    | Color Conversion    | CC           | Core, VM, S, I  |
    +---------------------+--------------+-----------------+
    | String Operations   | CH           | Core, VM, S     |
    +---------------------+--------------+-----------------+
    | Computer Vision     | CV           | Core, VM, S, I  |
    +---------------------+--------------+-----------------+
    | Data Compression    | DC           | Core, VM, S     |
    +---------------------+--------------+-----------------+
    | Image Processing    | I            | Core, VM, S     |
    +---------------------+--------------+-----------------+
    | Signal Processing   | S            | Core, VM        |
    +---------------------+--------------+-----------------+
    | Vector Math         | VM           | Core            |
    +---------------------+--------------+-----------------+


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``IPP::IPP``

Interface library that links to all found component libraries

#]=======================================================================]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    "${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES
    URL "https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html#gs.sd4x9g"
    DESCRIPTION "Hardware-accelerated functions for signal and image processing provided by Intel")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

find_path (
    IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
                                /opt/intel/oneapi/ipp/include ENV IPP_INCLUDE_DIR
    DOC "Intel IPP include directory")

set (IPP_ROOT "${IPP_INCLUDE_DIR}/.." CACHE PATH "Path to the root of the Intel IPP installation")

mark_as_advanced (IPP_INCLUDE_DIR IPP_ROOT)

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}" REQUIRED_VARS IPP_INCLUDE_DIR
                                                                              IPP_ROOT)

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

#

function (__oranges_find_ipp_component lib_name comp_required)

    if (TARGET IPP::${lib_name})
        return ()
    endif ()

    if ("${lib_name}" STREQUAL CC)
        set (comp_dependencies CORE VM S I)
    elseif ("${lib_name}" STREQUAL CH)
        set (comp_dependencies CORE VM S)
    elseif ("${lib_name}" STREQUAL CV)
        set (comp_dependencies CORE VM S I)
    elseif ("${lib_name}" STREQUAL DC)
        set (comp_dependencies CORE VM S)
    elseif ("${lib_name}" STREQUAL I)
        set (comp_dependencies CORE VM S)
    elseif ("${lib_name}" STREQUAL S)
        set (comp_dependencies CORE VM)
    elseif ("${lib_name}" STREQUAL VM)
        set (comp_dependencies CORE)
    else ()
        set (comp_dependencies "")
    endif ()

    foreach (dep_component IN LISTS comp_dependencies)
        if (NOT TARGET IPP::${dep_component})
            __oranges_find_ipp_component ("${dep_component}" "${comp_required}")

            if (NOT TARGET IPP::${dep_component})
                return ()
            endif ()
        endif ()
    endforeach ()

    string (TOLOWER "${lib_name}" lower_comp_name)

    set (baseName "ipp${lower_comp_name}")

    find_library (IPP_LIB_${lib_name} "${baseName}" PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
                  NO_DEFAULT_PATH DOC "Intel IPP ${lib_name} library")

    find_path (IPP_LIB_${lib_name}_INCLUDEDIR "${baseName}.h" PATHS "${IPP_ROOT}/include"
               NO_DEFAULT_PATH DOC "Header for Intel IPP ${lib_name} library")

    mark_as_advanced (IPP_LIB_${lib_name} IPP_LIB_${lib_name}_INCLUDEDIR)

    if (NOT (IPP_LIB_${lib_name} AND IPP_LIB_${lib_name}_INCLUDEDIR))
        return ()
    endif ()

    add_library (IPP::${lib_name} IMPORTED UNKNOWN)

    set_target_properties (IPP::${lib_name} PROPERTIES IMPORTED_LOCATION "${IPP_LIB_${lib_name}}")

    target_include_directories (IPP::${lib_name} INTERFACE "${IPP_LIB_${lib_name}_INCLUDEDIR}")

    target_sources (IPP::${lib_name} INTERFACE "${IPP_LIB_${lib_name}_INCLUDEDIR}/${baseName}.h")

    foreach (dep_component IN LISTS comp_dependencies)
        target_link_libraries (IPP::${lib_name} INTERFACE IPP::${dep_component})
    endforeach ()

endfunction ()

#

# cmake-format: off
set (valid_components
     AC CC CH CORE CP CV DC DI GEN I J M R S SC SR VC VM)
# cmake-format: on

find_package_default_component_list (${valid_components})

set (found_comps "")

foreach (ipp_component IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    __oranges_find_ipp_component ("${ipp_component}"
                                  "${${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_${ipp_component}}")

    if (TARGET IPP::${ipp_component})
        set (${CMAKE_FIND_PACKAGE_NAME}_${ipp_component}_FOUND TRUE)
        list (APPEND found_comps "${ipp_component}")
    else ()
        set (${CMAKE_FIND_PACKAGE_NAME}_${ipp_component}_FOUND FALSE)

        if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_${ipp_component})
            list (APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
                  "Component ${ipp_component} not found")
            set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
            break ()
        endif ()
    endif ()
endforeach ()

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

#

add_library (IPP::IPP IMPORTED INTERFACE)

foreach (comp_name IN LISTS valid_components)
    target_link_libraries (IPP::IPP INTERFACE "$<TARGET_NAME_IF_EXISTS:IPP::${comp_name}>")
endforeach ()

target_include_directories (IPP::IPP INTERFACE "${IPP_INCLUDE_DIR}")

target_sources (IPP::IPP INTERFACE "${IPP_INCLUDE_DIR}/ipp.h")

find_package_message (
    "${CMAKE_FIND_PACKAGE_NAME}"
    "IPP - found (found components ${found_comps})"
    "IPP [${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS}] [${found_comps}] [${IPP_INCLUDE_DIR}] [${IPP_ROOT}]"
    )
