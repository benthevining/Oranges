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

OrangesGeneratePlatformHeader
------------------------------

This module provides the function :command:`oranges_generate_platform_header()`.

.. command:: oranges_generate_platform_header

  ::

    oranges_generate_platform_header (TARGET <targetName>
                                     [BASE_NAME <baseName>]
                                     [HEADER <headerName>]
                                     [LANGUAGE <languageToUseForFeatureTests>]
                                     [INTERFACE]
                                     [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>])

Generates a header file containing various platform identifying macros for the current target platform.

A useful property of this module is that including it initializes all the `PLAT_` cache variables, so you can reference them.

The generated file will contain the following macros, where ``<baseName>`` is all uppercase and every macro is defined to either 0 or 1 unless otherwise noted:

.. table:: OS type macros

+---------------------+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Macro name          | Cache variable  | Value          | Notes                                                                                                                                       |
+=====================+=================+==============================================================================================================================================================+
| <baseName>_UNIX     | PLAT_UNIX       | 0 or 1         |                                                                                                                                             |
| <baseName>_POSIX    | PLAT_POSIX      | 0 or 1         |                                                                                                                                             |
| <baseName>_WINDOWS  | PLAT_WIN        | 0 or 1         |                                                                                                                                             |
| <baseName>_MINGW    | PLAT_MINGW      | 0 or 1         |                                                                                                                                             |
| <baseName>_LINUX    | PLAT_LINUX      | 0 or 1         |                                                                                                                                             |
| <baseName>_APPLE    | PLAT_APPLE      | 0 or 1         | True if the target platform is any Apple OS                                                                                                 |
| <baseName>_OSX      | PLAT_MACOSX     | 0 or 1         | True if the target platform is desktop MacOS.                                                                                               |
| <baseName>_IOS      | PLAT_IOS        | 0 or 1         | True for any iOS-like OS (iOS, tvOS, or watchOS)                                                                                            |
| <baseName>_ANDROID  | PLAT_ANDROID    | 0 or 1         |                                                                                                                                             |
| <baseName>_MOBILE   | PLAT_MOBILE     | 0 or 1         | True for iOS, watchOS, or Android                                                                                                           |
| <baseName>_EMBEDDED | PLAT_EMBEDDED   | 0 or 1         | True if the target is an embedded platform. This defaults to true if CMAKE_SYSTEM_NAME is Generic.                                          |
| <baseName>_OS_TYPE  | PLAT_OS_TYPE    | String literal | A string literal describing the OS type being run. Defaults to one of 'MacOSX', 'iOS', 'tvOS', 'watchOS', 'Windows', 'Linux', or 'Android'. |
+---------------------+-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. table: Compiler type macros

+---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
| Macro name                | Cache variable             | Value             | Notes                                                                                                |
+===========================+============================+===================+======================================================================================================+
| <baseName>_CLANG          | PLAT_CLANG_<lang>          | 0 or 1            | True if the compiler is Clang or AppleClang                                                          |
| <baseName>_GCC            | PLAT_GCC_<lang>            | 0 or 1            |                                                                                                      |
| <baseName>_MSVC           | PLAT_MSVC_<lang>           | 0 or 1            |                                                                                                      |
| <baseName>_INTEL_COMPILER | PLAT_INTEL_COMPILER_<lang> | 0 or 1            |                                                                                                      |
| <baseName>_CRAY_COMPILER  | PLAT_CRAY_COMPILER_<lang>  | 0 or 1            |                                                                                                      |
| <baseName>_ARM_COMPILER   | PLAT_ARM_COMPILER_<lang>   | 0 or 1            |                                                                                                      |
| <baseName>_COMPILER_TYPE  | PLAT_COMPILER_TYPE_<lang>  | String literal    | A string literal describing the compiler used. Either Clang, GCC, MSVC, Intel, ARM, Cray, or Unknown |
+---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+

.. table: Compiler version macros

+-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+
| Macro name                        | Cache variable                     | Value           | Notes                                                                         |
+===================================+====================================+=================+===============================================================================+
| <baseName>_COMPILER_VERSION_MAJOR | PLAT_COMPILER_VERSION_MAJOR_<lang> | Numeric literal | Number representing the compiler's major version, if available; otherwise, 0. |
| <baseName>_COMPILER_VERSION_MINOR | PLAT_COMPILER_VERSION_MINOR_<lang> | Numeric literal | Number representing the compiler's minor version, if available; otherwise, 0. |
| <baseName>_COMPILER_VERSION_PATCH | PLAT_COMPILER_VERSION_PATCH_<lang> | Numeric literal | Number representing the compiler's patch version, if available; otherwise, 0. |
| <baseName>_COMPILER_VERSION       | PLAT_COMPILER_VERSION_<lang>       | String literal  | A string literal describing the version of the compiler being used            |
+-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+

.. table: Processor and architecture macros

+--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
| Macro name               | Cache variable            | Value          | Notes                                                              |
+==========================+===========================+================+====================================================================+
| <baseName>_ARM           | PLAT_ARM                  | 0 or 1         |                                                                    |
| <baseName>_INTEL         | PLAT_INTEL                | 0 or 1         |                                                                    |
| <baseName>_CPU_TYPE      | PLAT_CPU_TYPE             | String literal | A string literal describing the CPU. Either ARM, Intel, or Unknown |
| <baseName>_32BIT         | PLAT_32BIT                | 0 or 1         |                                                                    |
| <baseName>_64BIT         | PLAT_64BIT                | 0 or 1         |                                                                    |
| <baseName>_BIG_ENDIAN    | PLAT_BIG_ENDIAN_<lang>    | 0 or 1         |                                                                    |
| <baseName>_LITTLE_ENDIAN | PLAT_LITTLE_ENDIAN_<lang> | 0 or 1         |                                                                    |
+--------------------------+---------------------------+----------------+--------------------------------------------------------------------+

.. table: SIMD instruction capabilities

+---------------------+----------------+--------+
| Macro name          | Cache variable | Value  |
+=====================+================+========+
| <baseName>_ARM_NEON | PLAT_ARM_NEON  | 0 or 1 |
| <baseName>_AVX      | PLAT_AVX       | 0 or 1 |
| <baseName>_AVX512   | PLAT_AVX512    | 0 or 1 |
| <baseName>_SSE      | PLAT_SSE       | 0 or 1 |
+---------------------+----------------+--------+

Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- PLAT_DISABLE_SIMD - if on, initializes all SIMD capability macros to 0.
- PLAT_DEFAULT_TESTING_LANGUAGE - specifies the language that will be used by default if none is specified when calling :command:`oranges_generate_platform_header()`. Additionally, the first time this file is included, all cache variables will be initialized using this language.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

option (PLAT_DISABLE_SIMD
        "Disable all SIMD macros in generated platform headers (ie, set them all to 0)" OFF)

set (PLAT_DEFAULT_TESTING_LANGUAGE CXX CACHE STRING
        "Language that will be used for platform detection tests that require referencing a specific compiler or language configuration")

set_property (CACHE PLAT_DEFAULT_TESTING_LANGUAGE PROPERTY
    STRINGS "CXX;C;OBJCXX;OBJC;Fortran;ASM")

include (scripts/plat_header_set_options)

_oranges_plat_header_set_opts_for_language ("${PLAT_DEFAULT_TESTING_LANGUAGE}")

#

function (oranges_generate_platform_header)

    oranges_add_function_message_context ()

    set (oneValueArgs TARGET BASE_NAME HEADER REL_PATH LANGUAGE INSTALL_COMPONENT)

    cmake_parse_arguments (ORANGES_ARG "INTERFACE" "${oneValueArgs}" "" ${ARGN})

    oranges_assert_target_argument_is_target (ORANGES_ARG)
    lemons_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
    endif ()

    string (TOUPPER "${ORANGES_ARG_BASE_NAME}" ORANGES_ARG_BASE_NAME)

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_platform.h")
    endif ()

    if (ORANGES_ARG_INTERFACE)
        set (public_vis INTERFACE)
    else ()
        set (public_vis PUBLIC)
    endif ()

    if (NOT ORANGES_ARG_REL_PATH)
        set (ORANGES_ARG_REL_PATH "${ORANGES_ARG_TARGET}")
    endif ()

    if (NOT ORANGES_ARG_LANGUAGE)
        set (ORANGES_ARG_LANGUAGE "${PLAT_DEFAULT_TESTING_LANGUAGE}")
    endif ()

    _oranges_plat_header_set_opts_for_language ("${ORANGES_ARG_LANGUAGE}")

    set (input_file "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/platform_header.h")
    set (generated_file "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

    configure_file ("${input_file}" "${generated_file}" @ONLY NEWLINE_STYLE UNIX)

    set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                                                                        "${input_file}")

    set_source_files_properties ("${generated_file}" TARGET_DIRECTORY "${ORANGES_ARG_TARGET}"
                                 PROPERTIES GENERATED ON)

    target_sources (
        "${ORANGES_ARG_TARGET}"
        "${public_vis}"
        $<BUILD_INTERFACE:${generated_file}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>
        )

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    install (FILES "${generated_file}"
             DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}" ${install_component})

    target_include_directories (
        "${ORANGES_ARG_TARGET}" "${public_vis}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction ()
