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

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: IPP_STATIC

True if static libraries should be found; if false, finds shared libraries. Defaults to ``ON``.

.. cmake:variable:: IPP_MULTI_THREADED

True if multithreaded versions of the libraries should be found. Defaults to ``OFF``.

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
- All
- CORE
- AC : audio coding
- CC : color conversion
- CH : string processing
- CP : cryptography
- CV : computer vision
- DC : data compression
- DI : data integrity
- GEN : generated functions
- I : image processing
- J : image compression
- R : rendering and 3D data processing
- M : small matrix operations
- S : signal processing
- SC : speech coding
- SR : speech recognition
- VC : video coding
- VM : vector math

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

#

macro (__ipp_unset_vars)
    unset (IPP_LIBNAME_SUFFIX)
    unset (IPP_LIB_TYPE)
    unset (IPP_LIBTYPE_PREFIX)
    unset (IPP_LIBTYPE_SUFFIX)
endmacro ()

cmake_language (DEFER CALL __ipp_unset_vars)

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

option (IPP_STATIC "Use static IPP libraries" ON)
option (IPP_MULTI_THREADED "Use multithreaded IPP libraries" OFF)

if (DEFINED ENV{IPP_ROOT})
    set (IPP_ROOT "$ENV{IPP_ROOT}" CACHE PATH "Path to the root of the Intel IPP installation")
endif ()

if (NOT (DEFINED IPP_INCLUDE_DIR OR DEFINED CACHE{IPP_INCLUDE_DIR} OR DEFINED ENV{IPP_INCLUDE_DIR}))
    set (IPP_INCLUDE_DIR "${IPP_ROOT}/include" CACHE PATH "Intel IPP include directory")
endif ()

if (NOT DEFINED CACHE{IPP_INCLUDE_DIR})
    find_path (
        IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
                                    /opt/intel/oneapi/ipp/include ENV IPP_INCLUDE_DIR
        DOC "Intel IPP include directory")

    if (IPP_INCLUDE_DIR)
        set (IPP_ROOT "${IPP_INCLUDE_DIR}/.."
             CACHE PATH "Path to the root of the Intel IPP installation")
    endif ()
endif ()

mark_as_advanced (IPP_STATIC IPP_MULTI_THREADED IPP_INCLUDE_DIR IPP_ROOT)

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}" REQUIRED_VARS IPP_INCLUDE_DIR
                                                                              IPP_ROOT)

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

#

if (IPP_STATIC)
    if (IPP_MULTI_THREADED)
        set (IPP_LIBNAME_SUFFIX _t)
    else ()
        set (IPP_LIBNAME_SUFFIX _l)
    endif ()

    set (IPP_LIB_TYPE STATIC)
    set (ipp_type static)
else ()
    set (IPP_LIBNAME_SUFFIX "")
    set (IPP_LIB_TYPE SHARED)
    set (ipp_type dynamic)
endif ()

set (IPP_LIBTYPE_PREFIX "${CMAKE_${IPP_LIB_TYPE}_LIBRARY_PREFIX}")
set (IPP_LIBTYPE_SUFFIX "${CMAKE_${IPP_LIB_TYPE}_LIBRARY_SUFFIX}")

if (WIN32)
    set (ipp_type_flag "/Qipp-link:${ipp_type}")
else ()
    set (ipp_type_flag "-ipp-link=${ipp_type}")
endif ()

unset (ipp_type)

set (ipp_linker_flags "$<$<CXX_COMPILER_ID:Intel,IntelLLVM>:${ipp_type_flag}>")

unset (ipp_type_flag)

#

function (__oranges_find_ipp_component lib_name comp_required)

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

    if (NOT TARGET IPP::${lib_name})
        string (TOLOWER "${lib_name}" lower_comp_name)

        set (baseName "ipp${lower_comp_name}")

        unset (lower_comp_name)

        find_library (
            IPP_LIB_${lib_name}
            NAMES "${baseName}" "${IPP_LIBTYPE_PREFIX}${baseName}"
                  "${IPP_LIBTYPE_PREFIX}${baseName}${IPP_LIBTYPE_SUFFIX}"
                  "${baseName}${IPP_LIBTYPE_SUFFIX}"
            PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
            NO_DEFAULT_PATH
            DOC "Intel IPP ${lib_name} library")

        mark_as_advanced (IPP_LIB_${lib_name})

        if (IPP_LIB_${lib_name})
            add_library (IPP::${lib_name} IMPORTED ${IPP_LIB_TYPE})

            set_target_properties (IPP::${lib_name} PROPERTIES IMPORTED_LOCATION
                                                               "${IPP_LIB_${lib_name}}")

            foreach (dep_component IN LISTS comp_dependencies)
                target_link_libraries (IPP::${lib_name} INTERFACE IPP::${dep_component})
            endforeach ()

            set (${CMAKE_FIND_PACKAGE_NAME}_${lib_name}_FOUND TRUE)

            if (NOT TARGET IPP::IPP)
                add_library (IPP::IPP IMPORTED INTERFACE)
            endif ()

            target_link_libraries (IPP::IPP INTERFACE IPP::${lib_name})
        endif ()
    endif ()

endfunction ()

#

find_package_default_component_list (
    CORE
    AC
    CC
    CH
    CP
    CV
    DC
    DI
    GEN
    I
    J
    R
    M
    S
    SC
    SR
    VC
    VM)

foreach (ipp_component IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    __oranges_find_ipp_component ("${ipp_component}"
                                  "${${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_${ipp_component}}")
endforeach ()

#

if (NOT TARGET IPP::IPP)
    return ()
endif ()

target_compile_options (IPP::IPP INTERFACE "${ipp_linker_flags}")

unset (ipp_linker_flags)

target_include_directories (IPP::IPP INTERFACE "$<BUILD_INTERFACE:${IPP_INCLUDE_DIR}>")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

find_package_message (
    "${CMAKE_FIND_PACKAGE_NAME}"
    "IPP - found (found components ${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS})"
    "IPP [${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS}] [${IPP_STATIC}] [${IPP_MULTI_THREADED}] [${IPP_INCLUDE_DIR}]"
    )
