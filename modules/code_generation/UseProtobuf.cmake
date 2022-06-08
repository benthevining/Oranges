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

UseProtobuf
-------------------------

Integrate Protobuf generated code into your projects.

Commands
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_add_protobuf_files

  ::

    oranges_add_protobuf_files (TARGET <target>
                                PROTO_FILES <files...>
                               [INSTALL_DIR <dir>]
                               [INSTALL_COMPONENT <component>]
                               [NO_PYTHON] | [PY_FILES_OUT <outVar>]
                               [NO_DESCRIPTORS])

Adds a command to generate C++ and Python code from a set of ``.proto`` files, and adds the generated C++ source files to the specified ``<target>``.

.. command:: oranges_add_protobuf_library

  ::

    oranges_add_protobuf_library (TARGET <target>
                                 [PROTO_FILES <files...>]
                                 [INSTALL_DIR <dir>]
                                 [INSTALL_COMPONENT <component>])

Creates a library target named ``<target>`` and calls :command:`oranges_add_protobuf_files` to add the given ``PROTO_FILES`` to the target.

The type of library created is controlled by the :variable:`PROTOBUF_LIBRARY_TYPE` variable.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PROTOBUF_LIBRARY_TYPE

Determines the type of library targets created by :command:`oranges_add_protobuf_library`, either ``STATIC`` or ``SHARED``.
Defaults to ``STATIC``.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

find_package (Protobuf REQUIRED)

set (PROTOBUF_LIBRARY_TYPE STATIC CACHE STRING
                                        "Type of libraries to create for building Protobuf code")

set_property (CACHE PROTOBUF_LIBRARY_TYPE PROPERTY STRINGS "STATIC;SHARED")
mark_as_advanced (PROTOBUF_LIBRARY_TYPE)

#

function (oranges_add_protobuf_files)

    set (options NO_PYTHON NO_DESCRIPTORS)
    set (oneValueArgs TARGET INSTALL_DIR INSTALL_COMPONENT PY_FILES_OUT)
    set (multiValueArgs PROTO_FILES)

    cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")

    # check target, PROTO_FILES. default for INSTALL_DIR. allow to set scope

    target_sources ("${ORANGES_ARG_TARGET}" PRIVATE ${ORANGES_ARG_PROTO_FILES})

    source_group (TREE "${CMAKE_CURRENT_LIST_DIR}" FILES ${ORANGES_ARG_PROTO_FILES} PREFIX proto)

    if (NOT ORANGES_ARG_NO_DESCRIPTORS)
        set (descriptor_flag DESCRIPTORS gen_desc)
    endif ()

    protobuf_generate_cpp (gen_cpp gen_h ${descriptor_flag} ${ORANGES_ARG_PROTO_FILES})

    set (proto_all_generated ${gen_cpp} ${gen_h} ${gen_desc})

    foreach (proto_file IN LISTS proto_all_generated)
        target_sources ("${ORANGES_ARG_TARGET}" PRIVATE "$<BUILD_INTERFACE:${proto_file}>")
    endforeach ()

    foreach (proto_header IN LISTS gen_h)
        cmake_path (GET proto_header FILENAME proto_header)

        target_sources ("${ORANGES_ARG_TARGET}"
                        PRIVATE "$<INSTALL_INTERFACE:${ORANGES_ARG_INSTALL_DIR}/${proto_header}>")
    endforeach ()

    target_link_libraries ("${ORANGES_ARG_TARGET}" PUBLIC protobuf::libprotobuf)

    target_include_directories (
        "${ORANGES_ARG_TARGET}" PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
                                       "$<INSTALL_INTERFACE:${ORANGES_ARG_INSTALL_DIR}>")

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    install (FILES ${gen_h} DESTINATION "${ORANGES_ARG_INSTALL_DIR}" ${install_component})

    source_group (TREE "${CMAKE_CURRENT_BINARY_DIR}" FILES ${proto_all_generated} PREFIX generated)

    list (TRANSFORM proto_all_generated
          PREPEND "${CMAKE_INSTALL_PREFIX}/${ORANGES_ARG_INSTALL_DIR}/")

    source_group (TREE "${CMAKE_INSTALL_PREFIX}/${ORANGES_ARG_INSTALL_DIR}"
                  FILES ${proto_all_generated} PREFIX proto)

    if (NOT ORANGES_ARG_NO_PYTHON)
        protobuf_generate_python (gen_py ${ORANGES_ARG_PROTO_FILES})

        if (ORANGES_ARG_PY_FILES_OUT)
            set (${ORANGES_ARG_PY_FILES_OUT} ${gen_py} PARENT_SCOPE)
        endif ()
    endif ()

endfunction ()

#

function (oranges_add_protobuf_library)

    set (oneValueArgs TARGET INSTALL_DIR INSTALL_COMPONENT)

    cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "PROTO_FILES" "${ARGN}")

    # check target, PROTO_FILES. default for INSTALL_DIR, INSTALL_COMPONENT.

    add_library ("${ORANGES_ARG_TARGET}" "${PROTOBUF_LIBRARY_TYPE}")

    if (ORANGES_ARG_PROTO_FILES)
        oranges_add_protobuf_files (
            TARGET "${ORANGES_ARG_TARGET}" INSTALL_DIR "${ORANGES_ARG_INSTALL_DIR}"
            INSTALL_COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}"
            PROTO_FILES ${ORANGES_ARG_PROTO_FILES})
    endif ()

endfunction ()
