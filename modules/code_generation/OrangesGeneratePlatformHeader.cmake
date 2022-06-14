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

This module provides the function :command:`oranges_generate_platform_header() <oranges_generate_platform_header>` and an extensive set of cache variables describing the current target platform.

.. contents:: Contents
    :depth: 1
    :local:
    :backlinks: top

The header generation command
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_generate_platform_header

  ::

    oranges_generate_platform_header (<targetName>
                                     [BASE_NAME <baseName>]
                                     [HEADER <headerName>]
                                     [LANGUAGE <languageToUseForFeatureTests>]
                                     [SCOPE <PUBLIC|PRIVATE|INTERFACE>]
                                     [INSTALL_COMPONENT <componentName>] [REL_PATH <installRelPath>])

Generates a header file containing various platform identifying macros for the current target platform.

The value of each macro in the generated header file will be set from a corresponding cache variable, which allows the user a high level of configurability, and the ability to override specific details about the current platform as needed.
The entire set of cache variables used to store platform attributes is initialized when this module is first included.
Thus, you can use this module's cache variables in your CMake scripts without actually generating a header file.

Options:

``BASE_NAME``
 Prefix to use for all macros in the generated header file. Defaults to ``<targetName>``.

``HEADER``
 Name of the header file to be generated. Defaults to ``<baseName>_platform.h``.

``LANGUAGE``
 Some of the platform introspection requires specifying a language, because some features may be compiler-specific.
 For these options, the cache variables are suffixed with ``<lang>`` (where ``lang`` is the language in all-uppercase), so that multiple settings can be saved (and overridden) for different languages.
 Defaults to the value of the :variable:`PLAT_DEFAULT_TESTING_LANGUAGE` variable.

``SCOPE``
 Scope with which the generated header will be added to the target. Defaults to ``INTERFACE`` for interface library targets, ``PRIVATE`` for executables, and ``PUBLIC`` for all other target types.

``INSTALL_COMPONENT``
 An install component the generated header will be added to. This command will not create the install component.

``REL_PATH``
 Path below ``CMAKE_INSTALL_INCLUDEDIR`` where the generated file will be installed to. Defaults to ``<targetName>``.

Macros
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The generated file will contain the following macros, where ``<baseName>`` and ``<lang>`` are all uppercase:

.. table:: OS type macros

    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | Macro name          | Cache variable  | Value          | Notes                                                                                                                                       |
    +=====================+=================+================+=============================================================================================================================================+
    | <baseName>_UNIX     | PLAT_UNIX       | 0 or 1         |                                                                                                                                             |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_POSIX    | PLAT_POSIX      | 0 or 1         |                                                                                                                                             |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_WINDOWS  | PLAT_WIN        | 0 or 1         |                                                                                                                                             |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_MINGW    | PLAT_MINGW      | 0 or 1         |                                                                                                                                             |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_LINUX    | PLAT_LINUX      | 0 or 1         |                                                                                                                                             |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_APPLE    | PLAT_APPLE      | 0 or 1         | True if the target platform is any Apple OS                                                                                                 |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_OSX      | PLAT_MACOSX     | 0 or 1         | True if the target platform is desktop MacOS.                                                                                               |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_IOS      | PLAT_IOS        | 0 or 1         | True for any iOS-like OS (iOS, tvOS, or watchOS)                                                                                            |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_ANDROID  | PLAT_ANDROID    | 0 or 1         |                                                                                                                                             |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_MOBILE   | PLAT_MOBILE     | 0 or 1         | True for iOS, watchOS, or Android                                                                                                           |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_EMBEDDED | PLAT_EMBEDDED   | 0 or 1         | True if the target is an embedded platform. This defaults to true if CMAKE_SYSTEM_NAME is Generic.                                          |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+
    | <baseName>_OS_TYPE  | PLAT_OS_TYPE    | String literal | A string literal describing the OS type being run. Defaults to one of 'MacOSX', 'iOS', 'tvOS', 'watchOS', 'Windows', 'Linux', or 'Android'. |
    +---------------------+-----------------+----------------+---------------------------------------------------------------------------------------------------------------------------------------------+

.. table:: Compiler type macros

    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | Macro name                | Cache variable             | Value             | Notes                                                                                                |
    +===========================+============================+===================+======================================================================================================+
    | <baseName>_CLANG          | PLAT_CLANG_<lang>          | 0 or 1            | True if the compiler is Clang or AppleClang                                                          |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | <baseName>_GCC            | PLAT_GCC_<lang>            | 0 or 1            |                                                                                                      |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | <baseName>_MSVC           | PLAT_MSVC_<lang>           | 0 or 1            |                                                                                                      |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | <baseName>_INTEL_COMPILER | PLAT_INTEL_COMPILER_<lang> | 0 or 1            |                                                                                                      |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | <baseName>_CRAY_COMPILER  | PLAT_CRAY_COMPILER_<lang>  | 0 or 1            |                                                                                                      |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | <baseName>_ARM_COMPILER   | PLAT_ARM_COMPILER_<lang>   | 0 or 1            |                                                                                                      |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+
    | <baseName>_COMPILER_TYPE  | PLAT_COMPILER_TYPE_<lang>  | String literal    | A string literal describing the compiler used. Either Clang, GCC, MSVC, Intel, ARM, Cray, or Unknown |
    +---------------------------+----------------------------+-------------------+------------------------------------------------------------------------------------------------------+

.. table:: Compiler version macros

    +-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+
    | Macro name                        | Cache variable                     | Value           | Notes                                                                         |
    +===================================+====================================+=================+===============================================================================+
    | <baseName>_COMPILER_VERSION_MAJOR | PLAT_COMPILER_VERSION_MAJOR_<lang> | Numeric literal | Number representing the compiler's major version, if available; otherwise, 0. |
    +-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+
    | <baseName>_COMPILER_VERSION_MINOR | PLAT_COMPILER_VERSION_MINOR_<lang> | Numeric literal | Number representing the compiler's minor version, if available; otherwise, 0. |
    +-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+
    | <baseName>_COMPILER_VERSION_PATCH | PLAT_COMPILER_VERSION_PATCH_<lang> | Numeric literal | Number representing the compiler's patch version, if available; otherwise, 0. |
    +-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+
    | <baseName>_COMPILER_VERSION       | PLAT_COMPILER_VERSION_<lang>       | String literal  | A string literal describing the version of the compiler being used            |
    +-----------------------------------+------------------------------------+-----------------+-------------------------------------------------------------------------------+

.. table:: Processor and architecture macros

    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | Macro name               | Cache variable            | Value          | Notes                                                              |
    +==========================+===========================+================+====================================================================+
    | <baseName>_ARM           | PLAT_ARM                  | 0 or 1         |                                                                    |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | <baseName>_INTEL         | PLAT_INTEL                | 0 or 1         |                                                                    |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | <baseName>_CPU_TYPE      | PLAT_CPU_TYPE             | String literal | A string literal describing the CPU. Either ARM, Intel, or Unknown |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | <baseName>_32BIT         | PLAT_32BIT                | 0 or 1         |                                                                    |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | <baseName>_64BIT         | PLAT_64BIT                | 0 or 1         |                                                                    |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | <baseName>_BIG_ENDIAN    | PLAT_BIG_ENDIAN_<lang>    | 0 or 1         |                                                                    |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+
    | <baseName>_LITTLE_ENDIAN | PLAT_LITTLE_ENDIAN_<lang> | 0 or 1         |                                                                    |
    +--------------------------+---------------------------+----------------+--------------------------------------------------------------------+

.. table:: SIMD instruction capabilities

    +---------------------+----------------+--------+
    | Macro name          | Cache variable | Value  |
    +=====================+================+========+
    | <baseName>_ARM_NEON | PLAT_ARM_NEON  | 0 or 1 |
    +---------------------+----------------+--------+
    | <baseName>_AVX      | PLAT_AVX       | 0 or 1 |
    +---------------------+----------------+--------+
    | <baseName>_AVX512   | PLAT_AVX512    | 0 or 1 |
    +---------------------+----------------+--------+
    | <baseName>_SSE      | PLAT_SSE       | 0 or 1 |
    +---------------------+----------------+--------+

.. note::

    Each macro used by this header file will always be defined to a value, so you should use ``#if`` to check their values, and not ``#ifdef``.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PLAT_DISABLE_SIMD

If on, all SIMD-related macros are initialized to 0, instead of attempting to detect features present with the current toolchain and target platform. Defaults to ``OFF``.

.. cmake:variable:: PLAT_DEFAULT_TESTING_LANGUAGE

The language that will be used to initialize the values of language- or compiler-specific variables the first time this module is included. Defaults to ``CXX``.

.. seealso ::

    Module :module:`OrangesGenerateStandardHeaders`
        An aggregate module that includes this one

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)

option (PLAT_DISABLE_SIMD
        "Disable all SIMD macros in generated platform headers (ie, set them all to 0)" OFF)

set (
    PLAT_DEFAULT_TESTING_LANGUAGE
    CXX
    CACHE
        STRING
        "Language that will be used for platform detection tests that require referencing a specific compiler or language configuration, when another language isn't explicitly specified"
    )

set_property (CACHE PLAT_DEFAULT_TESTING_LANGUAGE PROPERTY STRINGS "CXX;C;OBJCXX;OBJC;Fortran;ASM")

include (scripts/plat_header_set_options)

_oranges_plat_header_set_opts_for_language ("${PLAT_DEFAULT_TESTING_LANGUAGE}")

#

function (oranges_generate_platform_header)

    set (TARGET_NAME "${ARGV0}")

    if (NOT TARGET "${TARGET_NAME}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${TARGET_NAME} does not exist!")
        return ()
    endif ()

    set (oneValueArgs BASE_NAME HEADER REL_PATH LANGUAGE INSTALL_COMPONENT SCOPE)

    cmake_parse_arguments (PARSE_ARGV 1 ORANGES_ARG "" "${oneValueArgs}" "")

    lemons_check_for_unparsed_args (ORANGES_ARG)

    if (NOT ORANGES_ARG_BASE_NAME)
        set (ORANGES_ARG_BASE_NAME "${TARGET_NAME}")
    endif ()

    string (TOUPPER "${ORANGES_ARG_BASE_NAME}" ORANGES_ARG_BASE_NAME)

    if (NOT ORANGES_ARG_HEADER)
        set (ORANGES_ARG_HEADER "${ORANGES_ARG_BASE_NAME}_platform.h")
    endif ()

    if (NOT ORANGES_ARG_REL_PATH)
        set (ORANGES_ARG_REL_PATH "${TARGET_NAME}")
    endif ()

    if (NOT ORANGES_ARG_LANGUAGE)
        set (ORANGES_ARG_LANGUAGE "${PLAT_DEFAULT_TESTING_LANGUAGE}")
    endif ()

    if (NOT ORANGES_ARG_SCOPE)
        get_target_property (target_type "${TARGET_NAME}" TYPE)

        if ("${target_type}" STREQUAL INTERFACE_LIBRARY)
            set (ORANGES_ARG_SCOPE INTERFACE)
        elseif ("${target_type}" STREQUAL EXECUTABLE)
            set (ORANGES_ARG_SCOPE PUBLIC)
        else ()
            set (ORANGES_ARG_SCOPE PRIVATE)
        endif ()

        unset (target_type)
    endif ()

    string (TOUPPER "${ORANGES_ARG_LANGUAGE}" ORANGES_ARG_LANGUAGE)

    _oranges_plat_header_set_opts_for_language ("${ORANGES_ARG_LANGUAGE}")

    set (input_file "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/platform_header.h")
    set (generated_file "${CMAKE_CURRENT_BINARY_DIR}/${ORANGES_ARG_HEADER}")

    # NB. configure_file doesn't expand variable names recursively
    set (PLAT_CLANG "${PLAT_CLANG_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_GCC "${PLAT_GCC_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_MSVC "${PLAT_MSVC_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_INTEL_COMPILER "${PLAT_INTEL_COMPILER_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_CRAY_COMPILER "${PLAT_CRAY_COMPILER_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_ARM_COMPILER "${PLAT_ARM_COMPILER_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_COMPILER_TYPE "${PLAT_COMPILER_TYPE_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_COMPILER_VERSION_MAJOR "${PLAT_COMPILER_VERSION_MAJOR_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_COMPILER_VERSION_MINOR "${PLAT_COMPILER_VERSION_MINOR_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_COMPILER_VERSION_PATCH "${PLAT_COMPILER_VERSION_PATCH_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_COMPILER_VERSION "${PLAT_COMPILER_VERSION_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_BIG_ENDIAN "${PLAT_BIG_ENDIAN_${ORANGES_ARG_LANGUAGE}}")
    set (PLAT_LITTLE_ENDIAN "${PLAT_LITTLE_ENDIAN_${ORANGES_ARG_LANGUAGE}}")

    macro (_oph_convert_bool_cache_var cacheVar)
        if (${${cacheVar}})
            set (_${cacheVar} 1)
        else ()
            set (_${cacheVar} 0)
        endif ()
    endmacro ()

    _oph_convert_bool_cache_var (PLAT_UNIX)
    _oph_convert_bool_cache_var (PLAT_POSIX)
    _oph_convert_bool_cache_var (PLAT_WIN)
    _oph_convert_bool_cache_var (PLAT_MINGW)
    _oph_convert_bool_cache_var (PLAT_LINUX)
    _oph_convert_bool_cache_var (PLAT_APPLE)
    _oph_convert_bool_cache_var (PLAT_MACOSX)
    _oph_convert_bool_cache_var (PLAT_IOS)
    _oph_convert_bool_cache_var (PLAT_ANDROID)
    _oph_convert_bool_cache_var (PLAT_MOBILE)
    _oph_convert_bool_cache_var (PLAT_EMBEDDED)
    _oph_convert_bool_cache_var (PLAT_CLANG)
    _oph_convert_bool_cache_var (PLAT_GCC)
    _oph_convert_bool_cache_var (PLAT_MSVC)
    _oph_convert_bool_cache_var (PLAT_INTEL_COMPILER)
    _oph_convert_bool_cache_var (PLAT_CRAY_COMPILER)
    _oph_convert_bool_cache_var (PLAT_ARM_COMPILER)
    _oph_convert_bool_cache_var (PLAT_ARM)
    _oph_convert_bool_cache_var (PLAT_INTEL)
    _oph_convert_bool_cache_var (PLAT_64BIT)
    _oph_convert_bool_cache_var (PLAT_32BIT)
    _oph_convert_bool_cache_var (PLAT_BIG_ENDIAN)
    _oph_convert_bool_cache_var (PLAT_LITTLE_ENDIAN)
    _oph_convert_bool_cache_var (PLAT_ARM_NEON)
    _oph_convert_bool_cache_var (PLAT_AVX)
    _oph_convert_bool_cache_var (PLAT_AVX512)
    _oph_convert_bool_cache_var (PLAT_SSE)

    configure_file ("${input_file}" "${generated_file}" @ONLY NEWLINE_STYLE UNIX)

    set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                                                                        "${input_file}")

    set_source_files_properties ("${generated_file}" TARGET_DIRECTORY "${TARGET_NAME}"
                                 PROPERTIES GENERATED ON)

    target_sources (
        "${TARGET_NAME}"
        "${ORANGES_ARG_SCOPE}"
        $<BUILD_INTERFACE:${generated_file}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}/${ORANGES_ARG_HEADER}>
        )

    if (ORANGES_ARG_INSTALL_COMPONENT)
        set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
    endif ()

    install (FILES "${generated_file}"
             DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}" ${install_component})

    target_include_directories (
        "${TARGET_NAME}" "${ORANGES_ARG_SCOPE}" $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${ORANGES_ARG_REL_PATH}>)

endfunction ()
