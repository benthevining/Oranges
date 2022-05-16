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

A find module for the Intel IPP signal processing libraries.

Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- IPP_STATIC - defaults to on
- IPP_MULTI_THREADED - defaults to off

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- IPP_ROOT : this can be manually overridden to provide the path to the root of the IPP installation.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- IPP_FOUND

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

Each one produces an imported target named Intel::ipp_lib_<Component>.

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
- Intel::IntelIPP : interface library that links to all found component libraries

#]=======================================================================]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
    IPP PROPERTIES
    URL "https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html#gs.sd4x9g"
    DESCRIPTION "Hardware-accelerated functions for signal and image processing provided by Intel")

#

macro (_ipp_unset_vars)
    unset (IPP_ROOT)
    unset (IPP_LIBNAME_SUFFIX)
    unset (IPP_LIB_TYPE)
    unset (IPP_LIBTYPE_PREFIX)
    unset (IPP_LIBTYPE_SUFFIX)
endmacro ()

cmake_language (DEFER CALL _ipp_unset_vars)

#

oranges_file_scoped_message_context ("FindIPP")

set (IPP_FOUND FALSE)

#

option (IPP_STATIC "Use static IPP libraries" ON)
option (IPP_MULTI_THREADED "Use multithreaded IPP libraries" OFF)

mark_as_advanced (FORCE IPP_STATIC IPP_MULTI_THREADED)

#

find_path (
    IPP_INCLUDE_DIR ipp.h PATHS /opt/intel/ipp/include /opt/intel/oneapi/ipp/latest/include
                                /opt/intel/oneapi/ipp/include "${IPP_ROOT}/include"
    DOC "Intel IPP root directory")

mark_as_advanced (FORCE IPP_INCLUDE_DIR)

if (NOT IPP_INCLUDE_DIR OR NOT IS_DIRECTORY "${IPP_INCLUDE_DIR}")
    find_package_warning_or_error ("IPP include directory could not be located!")
    return ()
endif ()

set (IPP_ROOT "${IPP_INCLUDE_DIR}/.." CACHE PATH "Path to the root of the Intel IPP installation")

mark_as_advanced (FORCE IPP_ROOT)

if (NOT IS_DIRECTORY "${IPP_ROOT}")
    find_package_warning_or_error ("IPP root directory could not be located!")
    return ()
endif ()

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

function (_oranges_find_ipp_library lib_name comp_required)

    list (APPEND CMAKE_MESSAGE_CONTEXT "_oranges_find_ipp_library")

    if (TARGET ipp_lib_${lib_name})
        return ()
    endif ()

    string (TOLOWER "${lib_name}" IPP_COMPONENT_LOWER)

    set (baseName "ipp${IPP_COMPONENT_LOWER}")

    find_library (
        IPP_LIB_${lib_name}
        NAMES "${baseName}" "${IPP_LIBTYPE_PREFIX}${baseName}"
              "${IPP_LIBTYPE_PREFIX}${baseName}${IPP_LIBTYPE_SUFFIX}"
              "${baseName}${IPP_LIBTYPE_SUFFIX}"
        PATHS "${IPP_ROOT}/lib" "${IPP_ROOT}/lib/ia32"
        DOC "Intel IPP ${lib_name} library"
        NO_DEFAULT_PATH)

    mark_as_advanced (FORCE IPP_LIB_${lib_name})

    if (NOT IPP_LIB_${lib_name} OR NOT EXISTS "${IPP_LIB_${lib_name}}")
        if (comp_required)
            find_package_warning_or_error ("IPP component ${lib_name} could not be found!")
        endif ()
    endif ()

    find_package_message (IPP "IPP - found component library ${lib_name}"
                          "IPP - ${lib_name} - ${IPP_LIBTYPE_PREFIX} - ${IPP_LIBTYPE_SUFFIX}")

    add_library (ipp_lib_${lib_name} IMPORTED ${IPP_LIB_TYPE})

    set_target_properties (ipp_lib_${lib_name} PROPERTIES IMPORTED_LOCATION
                                                          "${IPP_LIB_${lib_name}}")

    if (NOT TARGET Intel::ipp_lib_${lib_name})
        add_library (Intel::ipp_lib_${lib_name} ALIAS ipp_lib_${lib_name})
    endif ()

    if (NOT TARGET IntelIPP)
        add_library (IntelIPP INTERFACE)
    endif ()

    target_link_libraries (IntelIPP INTERFACE Intel::ipp_lib_${lib_name})
endfunction ()

#

function (_oranges_find_ipp_component lib_name comp_required)

    list (APPEND CMAKE_MESSAGE_CONTEXT "_oranges_find_ipp_component")

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
        if (NOT TARGET ipp_lib_${dep_component})
            _oranges_find_ipp_component ("${dep_component}" TRUE)
        endif ()

        if (NOT TARGET ipp_lib_${dep_component})
            if (NOT IPP_FIND_QUIETLY)
                message (
                    WARNING
                        "IPP component ${lib_name} is missing dependent IPP component library ${dep_component}!"
                    )
            endif ()

            return ()
        endif ()
    endforeach ()

    _oranges_find_ipp_library ("${ipp_component}" "${comp_required}")

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

foreach (ipp_component ${IPP_FIND_COMPONENTS})

    _oranges_find_ipp_component ("${ipp_component}" "${IPP_FIND_REQUIRED_${ipp_component}}")

    if (IPP_FIND_REQUIRED_${ipp_component} AND NOT TARGET ipp_lib_${ipp_component})
        if (NOT IPP_FIND_QUIETLY)
            message (WARNING "IPP required component ${ipp_component} cannot be found!")
        endif ()

        return ()
    endif ()
endforeach ()

#

if (NOT TARGET IntelIPP)
    find_package_warning_or_error ("Error creating IntelIPP library target!")
    return ()
endif ()

target_compile_options (IntelIPP INTERFACE "${ipp_linker_flags}")

unset (ipp_linker_flags)

#

target_include_directories (
    IntelIPP INTERFACE $<BUILD_INTERFACE:${IPP_INCLUDE_DIR}>
                       $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/Intel/IPP>)

install (TARGETS IntelIPP EXPORT IntelIPPTargets)

install (EXPORT IntelIPPTargets DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/Intel/IPP"
         NAMESPACE Intel:: COMPONENT IntelIPP)

include (CPackComponent)

cpack_add_component (IntelIPP DISPLAY_NAME "Intel IPP" DESCRIPTION "Intel IPP libraries")

if (NOT TARGET Intel::IntelIPP)
    add_library (Intel::IntelIPP ALIAS IntelIPP)
endif ()

set (IPP_FOUND TRUE)

find_package_message (IPP "Found IPP - installed on system" "IPP - system")
