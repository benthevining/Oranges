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

FindMTS-ESP
-------------------------

A find module for the MTS-ESP MIDI tuning library.
If a local copy can't be found, the sources will be fetched from GitHub using CMake's ``FetchContent`` module.


Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Client
- Master
- All


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``MTS-ESP::Client``

Static library build of the MTS-ESP client library


``MTS-ESP::Master``

Static library build of the MTS-ESP master library


``MTS-ESP::MTS-ESP``

Interface library that links to both the client and master libraries (or only one of them, if the other could not be created for some reason)


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: MTSESP_SOURCE_DIR

This can be set to the root of a local copy of the MTS-ESP repository.


.. cmake:variable:: MTSESP_CLIENT_DIR

The path to the sources for the MTS-ESP client library.
When searching for this path, the environment variable :envvar:`MTSESP_CLIENT_DIR` is added to the search path.


.. cmake:variable:: MTSESP_MASTER_DIR

The path to the sources for the MTS-ESP client library.
When searching for this path, the environment variable :envvar:`MTSESP_MASTER_DIR` is added to the search path.


.. cmake:variable:: MTSESP_LIB_MTS

The path to the MTS-ESP prebuilt shared library used by the Master API to connect to its clients.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: MTSESP_SOURCE_DIR

This environment variable initializes the value of the :variable:`MTSESP_SOURCE_DIR` variable.


.. cmake:envvar:: MTSESP_CLIENT_DIR

This environment variable, if set, is added to the search path when locating the :variable:`MTSESP_CLIENT_DIR` variable.


.. cmake:envvar:: MTSESP_MASTER_DIR

This environment variable, if set, is added to the search path when locating the :variable:`MTSESP_MASTER_DIR` variable.

#]=======================================================================]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://oddsound.com/index.php"
                        DESCRIPTION "MIDI master/client microtuning tuning library")

#

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
set (${CMAKE_FIND_PACKAGE_NAME}_Client_FOUND FALSE)
set (${CMAKE_FIND_PACKAGE_NAME}_Master_FOUND FALSE)
set (${CMAKE_FIND_PACKAGE_NAME}_All_FOUND FALSE)

#

find_path (
    MTSESP_CLIENT_DIR libMTSClient.h PATHS "${MTSESP_SOURCE_DIR}/Client" ENV MTSESP_CLIENT_DIR
    DOC "MTS-ESP client sources directory")

find_path (
    MTSESP_MASTER_DIR libMTSMaster.h PATHS "${MTSESP_SOURCE_DIR}/Master" ENV MTSESP_MASTER_DIR
    DOC "MTS-ESP master sources directory")

if (MTSESP_CLIENT_DIR)
    set (mtsesp_source_init "${MTSESP_CLIENT_DIR}")
elseif (MTSESP_MASTER_DIR)
    set (mtsesp_source_init "${MTSESP_MASTER_DIR}")
else ()
    set (mtsesp_source_init "$ENV{MTSESP_SOURCE_DIR}")
endif ()

set (MTSESP_SOURCE_DIR "${mtsesp_source_init}" CACHE PATH "Path to the MTS-ESP repository")

unset (mtsesp_source_init)

mark_as_advanced (MTSESP_CLIENT_DIR MTSESP_MASTER_DIR MTSESP_SOURCE_DIR)

#

find_package_default_component_list (Client Master)

if (Client IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (MTSESP_CLIENT_DIR)
        if (NOT TARGET MTS-ESP::Client)
            add_library (MTS-ESP::Client STATIC)

            target_sources (MTS-ESP::Client PRIVATE "${MTSESP_CLIENT_DIR}/libMTSClient.cpp"
                            PUBLIC "${MTSESP_CLIENT_DIR}/libMTSClient.h")

            target_include_directories (MTS-ESP::Client PUBLIC "${MTSESP_CLIENT_DIR}")
        endif ()

        set (${CMAKE_FIND_PACKAGE_NAME}_Client_FOUND TRUE)
    else ()
        set (${CMAKE_FIND_PACKAGE_NAME}_Client_FOUND FALSE)

        if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Client)
            set (${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Client component not found")
        endif ()
    endif ()
endif ()

if (Master IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (TARGET MTS-ESP::Master)
        set (${CMAKE_FIND_PACKAGE_NAME}_Master_FOUND TRUE)
    elseif (MTSESP_MASTER_DIR)
        # locate the libMTS dynamic library
        if (NOT TARGET MTS-ESP::libMTS)
            if (WIN32)
                set (libMTS_name libMTS.dll)

                if (CMAKE_SIZEOF_VOID_P EQUAL 4) # 32-bit
                    set (libMTS_paths "Program Files (x86)\\Common Files\\MTS-ESP"
                                      "${MTSESP_SOURCE_DIR}/libMTS/Win/32bit")
                elseif (CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
                    set (libMTS_paths "Program Files\\Common Files\\MTS-ESP"
                                      "${MTSESP_SOURCE_DIR}/libMTS/Win/64bit")
                endif ()
            elseif (APPLE)
                set (libMTS_name libMTS.dylib)
                set (
                    libMTS_paths
                    "/Library/Application Support/MTS-ESP"
                    "${MTSESP_SOURCE_DIR}/libMTS/Mac/i386_x86_64"
                    "${MTSESP_SOURCE_DIR}/libMTS/Mac/x86_64_ARM")
            else () # Linux
                set (libMTS_name libMTS.so)
                set (libMTS_paths "/usr/local/lib" "${MTSESP_SOURCE_DIR}/libMTS/Linux/x86_64")
            endif ()

            find_library (
                MTSESP_LIB_MTS
                NAMES libMTS "${libMTS_name}"
                PATHS "${libMTS_paths}"
                DOC "MTS-ESP master dynamic library"
                NO_DEFAULT_PATH)

            mark_as_advanced (MTSESP_LIB_MTS)

            unset (libMTS_paths)
            unset (libMTS_name)

            if (MTSESP_LIB_MTS)
                add_library (MTS-ESP::libMTS IMPORTED UNKNOWN)

                set_target_properties (MTS-ESP::libMTS PROPERTIES IMPORTED_LOCATION
                                                                  "${MTSESP_LIB_MTS}")

                find_package_detect_macos_arch (MTS-ESP::libMTS "${MTSESP_LIB_MTS}")
            endif ()
        endif ()

        if (TARGET MTS-ESP::libMTS)
            add_library (MTS-ESP::Master STATIC)

            target_link_libraries (MTS-ESP::Master PRIVATE MTS-ESP::libMTS)

            target_sources (MTS-ESP::Master PRIVATE "${MTSESP_MASTER_DIR}/libMTSMaster.cpp"
                            PUBLIC "${MTSESP_MASTER_DIR}/libMTSMaster.h")

            target_include_directories (MTS-ESP::Master PUBLIC "${MTSESP_MASTER_DIR}")

            set (${CMAKE_FIND_PACKAGE_NAME}_Master_FOUND TRUE)
        else ()
            set (${CMAKE_FIND_PACKAGE_NAME}_Master_FOUND FALSE)

            if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Master)
                list (APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
                      "libMTS library not found")
            endif ()
        endif ()
    else ()
        set (${CMAKE_FIND_PACKAGE_NAME}_Master_FOUND FALSE)

        if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_Master)
            list (APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Master component not found")
        endif ()
    endif ()
endif ()

#

if (NOT (TARGET MTS-ESP::Client OR TARGET MTS-ESP::Master))
    return ()
endif ()

if (NOT TARGET MTS-ESP::MTS-ESP)
    add_library (MTS-ESP::MTS-ESP IMPORTED INTERFACE)
endif ()

target_link_libraries (MTS-ESP::MTS-ESP INTERFACE "$<TARGET_NAME_IF_EXISTS:MTS-ESP::Client>"
                                                  "$<TARGET_NAME_IF_EXISTS:MTS-ESP::Master>")

set (${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)

foreach (comp_name IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED_${comp_name}
        AND NOT ${CMAKE_FIND_PACKAGE_NAME}_${comp_name}_FOUND)
        set (${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    endif ()
endforeach ()

if (TARGET MTS-ESP::Client)
    set (found_components Client)
endif ()

if (TARGET MTS-ESP::Master)
    list (APPEND found_components Master)
endif ()

find_package_message (
    "${CMAKE_FIND_PACKAGE_NAME}"
    "MTS-ESP - found components ${found_components}"
    "MTS-ESP [${found_components}] [${MTSESP_CLIENT_DIR}] [${MTSESP_MASTER_DIR}] [${MTSESP_LIB_MTS}]"
    )

unset (found_components)
unset (mtsesp_find_location)
