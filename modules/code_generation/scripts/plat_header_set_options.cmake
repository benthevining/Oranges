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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

set (doc_plat_os_type "String literal describing the target OS")

#

set (doc_plat_arm_neon "True if the target CPU supports ARM NEON instructions")
set (doc_plat_avx "True if the target CPU supports AVX instructions")
set (doc_plat_avx512 "True if the target CPU supports AVX-512 instructions")
set (doc_plat_sse "True if the target CPU supports SSE instructions")

if (PLAT_DISABLE_SIMD)
    set (PLAT_ARM_NEON 0 CACHE BOOL "${doc_plat_arm_neon}")
    set (PLAT_AVX 0 CACHE BOOL "${doc_plat_avx}")
    set (PLAT_AVX512 0 CACHE BOOL "${doc_plat_avx512}")
    set (PLAT_SSE 0 CACHE BOOL "${doc_plat_sse}")
endif ()

#

macro (_oph_set_ifndef var)
    if (NOT (DEFINED ${var} OR DEFINED CACHE{${var}}))
        set ("${var}" ${ARGN})
    endif ()
endmacro ()

#

set (doc_plat_win "True if the target platform is Windows")

if (NOT (DEFINED MINGW OR DEFINED{MINGW}))
    if (MINGW)
        _oph_set_ifndef (PLAT_MINGW 1 CACHE BOOL "True if the target platform is MinGW")
        _oph_set_ifndef (PLAT_WIN 1 CACHE BOOL "${doc_plat_win}")
        _oph_set_ifndef (PLAT_OS_TYPE Windows CACHE STRING "${doc_plat_os_type}")
    else ()
        _oph_set_ifndef (PLAT_MINGW 0 CACHE BOOL "True if the target platform is MinGW")
    endif ()
endif ()

if (WIN32)
    _oph_set_ifndef (PLAT_WIN 1 CACHE BOOL "${doc_plat_win}")
    _oph_set_ifndef (PLAT_OS_TYPE Windows CACHE STRING "${doc_plat_os_type}")
else ()
    _oph_set_ifndef (PLAT_WIN 0 CACHE BOOL "${doc_plat_win}")
endif ()

unset (doc_plat_win)

#

if (APPLE
    OR IOS
    OR ("${CMAKE_SYSTEM_NAME}" STREQUAL Darwin)
    OR ("${CMAKE_SYSTEM_NAME}" STREQUAL iOS)
    OR ("${CMAKE_SYSTEM_NAME}" STREQUAL tvOS)
    OR ("${CMAKE_SYSTEM_NAME}" STREQUAL watchOS))
    _oph_set_ifndef (PLAT_APPLE 1 CACHE BOOL "True if the target platform is any Apple OS")
else ()
    _oph_set_ifndef (PLAT_APPLE 0 CACHE BOOL "True if the target platform is any Apple OS")
endif ()

#

set (doc_plat_macosx "True if the target platform is desktop MacOS")

if (IOS OR ("${CMAKE_SYSTEM_NAME}" STREQUAL iOS) OR ("${CMAKE_SYSTEM_NAME}" STREQUAL tvOS)
    OR ("${CMAKE_SYSTEM_NAME}" STREQUAL watchOS))
    _oph_set_ifndef (PLAT_IOS 1 CACHE BOOL "True if the target platform is iOS, tvOS or watchOS")
    _oph_set_ifndef (PLAT_MACOSX 0 CACHE BOOL "${doc_plat_macosx}")
    _oph_set_ifndef (PLAT_OS_TYPE "${CMAKE_SYSTEM_NAME}" CACHE STRING "${doc_plat_os_type}")
else ()
    _oph_set_ifndef (PLAT_IOS 0 CACHE BOOL "True if the target platform is iOS, tvOS or watchOS")

    if (PLAT_APPLE)
        _oph_set_ifndef (PLAT_MACOSX 1 CACHE BOOL "${doc_plat_macosx}")
        _oph_set_ifndef (PLAT_OS_TYPE MacOSX CACHE STRING "${doc_plat_os_type}")
    else ()
        _oph_set_ifndef (PLAT_MACOSX 0 CACHE BOOL "${doc_plat_macosx}")
    endif ()
endif ()

unset (doc_plat_macosx)

if (ANDROID OR ("${CMAKE_SYSTEM_NAME}" STREQUAL Android))
    _oph_set_ifndef (PLAT_ANDROID 1 CACHE BOOL "True if the target platform is Android")
    _oph_set_ifndef (PLAT_OS_TYPE Android CACHE STRING "${doc_plat_os_type}")
else ()
    _oph_set_ifndef (PLAT_ANDROID 0 CACHE BOOL "True if the target platform is Android")
endif ()

if (PLAT_ANDROID OR (PLAT_IOS AND NOT ("${CMAKE_SYSTEM_NAME}" STREQUAL tvOS)))
    _oph_set_ifndef (PLAT_MOBILE 1 CACHE BOOL "True if the target platform is any mobile platform")
else ()
    _oph_set_ifndef (PLAT_MOBILE 0 CACHE BOOL "True if the target platform is any mobile platform")
endif ()

#

if (("${CMAKE_SYSTEM_NAME}" MATCHES Linux) OR (NOT (PLAT_WIN OR PLAT_APPLE OR PLAT_ANDROID)))
    _oph_set_ifndef (PLAT_LINUX 1 CACHE BOOL "True if the target platform is Linux")
    _oph_set_ifndef (PLAT_OS_TYPE Linux CACHE STRING "${doc_plat_os_type}")
else ()
    _oph_set_ifndef (PLAT_LINUX 0 CACHE BOOL "True if the target platform is Linux")
endif ()

if ("${CMAKE_SYSTEM_NAME}" MATCHES Generic)
    _oph_set_ifndef (PLAT_EMBEDDED 1 CACHE BOOL "True if the target platform is an embedded device")
else ()
    _oph_set_ifndef (PLAT_EMBEDDED 0 CACHE BOOL "True if the target platform is an embedded device")
endif ()

if (UNIX OR PLAT_APPLE OR PLAT_LINUX)
    _oph_set_ifndef (PLAT_UNIX 1 CACHE BOOL "True if the target platform is Unix")
else ()
    _oph_set_ifndef (PLAT_UNIX 0 CACHE BOOL "True if the target platform is Unix")
endif ()

#

_oph_set_ifndef (PLAT_OS_TYPE Unknown CACHE STRING "${doc_plat_os_type}")

set_property (CACHE PLAT_OS_TYPE PROPERTY STRINGS "MacOSX;iOS;tvOS;watchOS;Windows;Linux;Android")

unset (doc_plat_os_type)

#

if (NOT ((DEFINED PLAT_64BIT OR DEFINED CACHE{PLAT_64BIT}) AND (DEFINED PLAT_32BIT
                                                                OR DEFINED CACHE{PLAT_32BIT})))
    cmake_host_system_information (RESULT is_64_bit QUERY IS_64BIT)

    if (is_64_bit)
        _oph_set_ifndef (PLAT_64BIT 1 CACHE BOOL "True if the target platform is 64-bit")
        _oph_set_ifndef (PLAT_32BIT 0 CACHE BOOL "True if the target platform is 32-bit")
    else ()
        _oph_set_ifndef (PLAT_64BIT 0 CACHE BOOL "True if the target platform is 64-bit")
        _oph_set_ifndef (PLAT_32BIT 1 CACHE BOOL "True if the target platform is 32-bit")
    endif ()

    unset (is_64_bit)
endif ()

#

_oph_set_ifndef (doc_plat_arm "True if the target platform is an ARM CPU")
_oph_set_ifndef (doc_plat_intel "True if the target platform is an Intel CPU")

if (PLAT_WIN)
    if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" MATCHES "ARM64")
        _oph_set_ifndef (PLAT_ARM 1 CACHE BOOL "${doc_plat_arm}")
        _oph_set_ifndef (PLAT_INTEL 0 CACHE BOOL "${doc_plat_intel}")
    else ()
        _oph_set_ifndef (PLAT_ARM 0 CACHE BOOL "${doc_plat_arm}")
        _oph_set_ifndef (PLAT_INTEL 1 CACHE BOOL "${doc_plat_intel}")
    endif ()
elseif (PLAT_APPLE)
    if (CMAKE_APPLE_SILICON_PROCESSOR)
        _oph_set_ifndef (_apple_plat_var_to_check CMAKE_APPLE_SILICON_PROCESSOR)
    else ()
        _oph_set_ifndef (_apple_plat_var_to_check CMAKE_HOST_SYSTEM_PROCESSOR)
    endif ()

    if ("${${_apple_plat_var_to_check}}" MATCHES arm64)
        _oph_set_ifndef (PLAT_ARM 1 CACHE BOOL "${doc_plat_arm}")
        _oph_set_ifndef (PLAT_INTEL 0 CACHE BOOL "${doc_plat_intel}")
    elseif ("${${_apple_plat_var_to_check}}" MATCHES x86_64)
        _oph_set_ifndef (PLAT_ARM 0 CACHE BOOL "${doc_plat_arm}")
        _oph_set_ifndef (PLAT_INTEL 1 CACHE BOOL "${doc_plat_intel}")
    endif ()

    unset (_apple_plat_var_to_check)
endif ()

if (NOT ((DEFINED PLAT_ARM) OR (DEFINED CACHE{PLAT_ARM}) OR (DEFINED PLAT_INTEL)
         OR (DEFINED CACHE{PLAT_INTEL})))
    try_compile (compile_result "${CMAKE_CURRENT_BINARY_DIR}/try_compile"
                 "${CMAKE_CURRENT_LIST_DIR}/check_arm.cpp" OUTPUT_VARIABLE compile_output)

    string (REGEX REPLACE ".*ORANGES_ARM ([a-zA-Z0-9_-]*).*" "\\1" is_arm "${compile_output}")

    if (is_arm)
        _oph_set_ifndef (PLAT_ARM 1 CACHE BOOL "${doc_plat_arm}")
        _oph_set_ifndef (PLAT_INTEL 0 CACHE BOOL "${doc_plat_intel}")
    else ()
        _oph_set_ifndef (PLAT_ARM 0 CACHE BOOL "${doc_plat_arm}")
        _oph_set_ifndef (PLAT_INTEL 1 CACHE BOOL "${doc_plat_intel}")
    endif ()

    unset (compile_result)
    unset (compile_output)
    unset (is_arm)
endif ()

unset (doc_plat_arm)
unset (doc_plat_intel)

_oph_set_ifndef (doc_plat_cpu_type "String literal describing the target CPU")

if (PLAT_ARM)
    _oph_set_ifndef (PLAT_CPU_TYPE ARM CACHE STRING "${doc_plat_cpu_type}")
elseif (PLAT_INTEL)
    _oph_set_ifndef (PLAT_CPU_TYPE Intel CACHE STRING "${doc_plat_cpu_type}")
else ()
    _oph_set_ifndef (PLAT_CPU_TYPE Unknown CACHE STRING "${doc_plat_cpu_type}")
endif ()

unset (doc_plat_cpu_type)

set_property (CACHE PLAT_CPU_TYPE PROPERTY STRINGS "ARM;Intel;Unknown")

#

if (PLAT_APPLE OR PLAT_ANDROID OR PLAT_MINGW OR PLAT_LINUX)
    _oph_set_ifndef (PLAT_POSIX 1 CACHE BOOL "True if the target platform is POSIX")
else ()
    _oph_set_ifndef (PLAT_POSIX 0 CACHE BOOL "True if the target platform is POSIX")
endif ()

#

if (NOT (DEFINED PLAT_ARM_NEON OR DEFINED CACHE{PLAT_ARM_NEON}))
    if (PLAT_ARM)
        try_compile (compile_result "${CMAKE_CURRENT_BINARY_DIR}/try_compile"
                     "${CMAKE_CURRENT_LIST_DIR}/check_arm_neon.cpp" OUTPUT_VARIABLE compile_output)

        string (REGEX REPLACE ".*ORANGES_ARM_NEON ([a-zA-Z0-9_-]*).*" "\\1" has_arm_neon
                              "${compile_output}")

        if (has_arm_neon)
            _oph_set_ifndef (PLAT_ARM_NEON 1 CACHE BOOL "${doc_plat_arm_neon}")
        else ()
            _oph_set_ifndef (PLAT_ARM_NEON 0 CACHE BOOL "${doc_plat_arm_neon}")
        endif ()

        unset (compile_result)
        unset (compile_output)
        unset (has_arm_neon)
    else ()
        _oph_set_ifndef (PLAT_ARM_NEON 0 CACHE BOOL "${doc_plat_arm_neon}")
    endif ()
endif ()

unset (doc_plat_arm_neon)

#

if (PLAT_INTEL)
    if (NOT (DEFINED PLAT_SSE OR DEFINED CACHE{PLAT_SSE}))
        try_compile (compile_result "${CMAKE_CURRENT_BINARY_DIR}/try_compile"
                     "${CMAKE_CURRENT_LIST_DIR}/check_sse.cpp" OUTPUT_VARIABLE compile_output)

        string (REGEX REPLACE ".*ORANGES_SSE ([a-zA-Z0-9_-]*).*" "\\1" has_sse "${compile_output}")

        if (has_sse)
            _oph_set_ifndef (PLAT_SSE 1 CACHE BOOL "${doc_plat_sse}")
        else ()
            _oph_set_ifndef (PLAT_SSE 0 CACHE BOOL "${doc_plat_sse}")
        endif ()

        unset (compile_result)
        unset (compile_output)
        unset (has_sse)
    endif ()

    #

    if (NOT (DEFINED PLAT_AVX512 OR DEFINED CACHE{PLAT_AVX512}))
        try_compile (compile_result "${CMAKE_CURRENT_BINARY_DIR}/try_compile"
                     "${CMAKE_CURRENT_LIST_DIR}/check_avx512.cpp" OUTPUT_VARIABLE compile_output)

        string (REGEX REPLACE ".*ORANGES_AVX512 ([a-zA-Z0-9_-]*).*" "\\1" has_avx512
                              "${compile_output}")

        if (has_avx512)
            _oph_set_ifndef (PLAT_AVX512 1 CACHE BOOL "${doc_plat_avx512}")
        else ()
            _oph_set_ifndef (PLAT_AVX512 0 CACHE BOOL "${doc_plat_avx512}")
        endif ()

        unset (compile_result)
        unset (compile_output)
        unset (has_avx512)
    endif ()

    #

    if (NOT (DEFINED PLAT_AVX OR DEFINED CACHE{PLAT_AVX}))
        if (PLAT_AVX512)
            _oph_set_ifndef (PLAT_AVX 0 CACHE BOOL "${doc_plat_avx}")
        else ()
            try_compile (compile_result "${CMAKE_CURRENT_BINARY_DIR}/try_compile"
                         "${CMAKE_CURRENT_LIST_DIR}/check_avx.cpp" OUTPUT_VARIABLE compile_output)

            string (REGEX REPLACE ".*ORANGES_AVX ([a-zA-Z0-9_-]*).*" "\\1" has_avx
                                  "${compile_output}")

            if (has_avx)
                _oph_set_ifndef (PLAT_AVX 1 CACHE BOOL "${doc_plat_avx}")
            else ()
                _oph_set_ifndef (PLAT_AVX 0 CACHE BOOL "${doc_plat_avx}")
            endif ()

            unset (compile_result)
            unset (compile_output)
            unset (has_avx)

        endif ()
    endif ()
else ()
    _oph_set_ifndef (PLAT_SSE 0 CACHE BOOL "${doc_plat_sse}")
    _oph_set_ifndef (PLAT_AVX 0 CACHE BOOL "${doc_plat_avx}")
    _oph_set_ifndef (PLAT_AVX512 0 CACHE BOOL "${doc_plat_avx512}")
endif ()

unset (doc_plat_avx)
unset (doc_plat_avx512)

# ###############################################################################################################

function (_oranges_plat_header_set_opts_for_language language)

    enable_language ("${language}")

    if (CMAKE_${language}_COMPILER_VERSION)
        _oph_set_ifndef (PLAT_COMPILER_VERSION_${language} "${CMAKE_${language}_COMPILER_VERSION}"
                         CACHE STRING "The compiler's full version string")

        string (REPLACE "." ";" version_list "${PLAT_COMPILER_VERSION_${language}}")

        list (GET version_list 0 version_major)
        list (GET version_list 1 version_minor)
        list (GET version_list 2 version_patch)

        unset (version_list)

        if (version_major)
            _oph_set_ifndef (PLAT_COMPILER_VERSION_MAJOR_${language} "${version_major}" CACHE
                             STRING "Major component of the compiler's version")
        else ()
            _oph_set_ifndef (PLAT_COMPILER_VERSION_MAJOR_${language} 0 CACHE STRING
                             "Major component of the compiler's version")
        endif ()

        unset (version_major)

        if (version_minor)
            _oph_set_ifndef (PLAT_COMPILER_VERSION_MINOR_${language} "${version_minor}" CACHE
                             STRING "Minor component of the compiler's version")
        else ()
            _oph_set_ifndef (PLAT_COMPILER_VERSION_MINOR_${language} 0 CACHE STRING
                             "Minor component of the compiler's version")
        endif ()

        unset (version_minor)

        if (version_patch)
            _oph_set_ifndef (PLAT_COMPILER_VERSION_PATCH_${language} "${version_patch}" CACHE
                             STRING "Patch component of the compiler's version")
        else ()
            _oph_set_ifndef (PLAT_COMPILER_VERSION_PATCH_${language} 0 CACHE STRING
                             "Patch component of the compiler's version")
        endif ()

        unset (version_patch)
    else ()
        _oph_set_ifndef (PLAT_COMPILER_VERSION_${language} Unknown CACHE STRING
                         "The compiler's full version string")
        _oph_set_ifndef (PLAT_COMPILER_VERSION_MAJOR_${language} 0 CACHE STRING
                         "Major component of the compiler's version")
        _oph_set_ifndef (PLAT_COMPILER_VERSION_MINOR_${language} 0 CACHE STRING
                         "Minor component of the compiler's version")
        _oph_set_ifndef (PLAT_COMPILER_VERSION_PATCH_${language} 0 CACHE STRING
                         "Patch component of the compiler's version")
    endif ()

    #

    set (doc_plat_compiler_type "String literal describing the compiler")

    set (compilerID "${CMAKE_${language}_COMPILER_ID}")

    if ("${compilerID}" MATCHES Clang)
        _oph_set_ifndef (PLAT_CLANG_${language} 1 CACHE BOOL
                         "True if the compiler is Clang or AppleClang")
        _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} "${compilerID}" CACHE STRING
                         "${doc_plat_compiler_type}")
    else ()
        _oph_set_ifndef (PLAT_CLANG_${language} 0 CACHE BOOL
                         "True if the compiler is Clang or AppleClang")
    endif ()

    if ("${compilerID}" MATCHES GNU)
        _oph_set_ifndef (PLAT_GCC_${language} 1 CACHE BOOL "True if the compiler is GCC")
        _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} "${compilerID}" CACHE STRING
                         "${doc_plat_compiler_type}")
    else ()
        _oph_set_ifndef (PLAT_GCC_${language} 0 CACHE BOOL "True if the compiler is GCC")
    endif ()

    if ("${compilerID}" MATCHES MSVC)
        _oph_set_ifndef (PLAT_MSVC_${language} 1 CACHE BOOL "True if the compiler is MSVC")
        _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} "${compilerID}" CACHE STRING
                         "${doc_plat_compiler_type}")
    else ()
        _oph_set_ifndef (PLAT_MSVC_${language} 0 CACHE BOOL "True if the compiler is MSVC")
    endif ()

    if (("${compilerID}" MATCHES Intel) OR ("${compilerID}" MATCHES IntelLLVM))
        _oph_set_ifndef (PLAT_INTEL_COMPILER_${language} 1 CACHE BOOL
                         "True if the compiler is Intel")
        _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} "${compilerID}" CACHE STRING
                         "${doc_plat_compiler_type}")
    else ()
        _oph_set_ifndef (PLAT_INTEL_COMPILER_${language} 0 CACHE BOOL
                         "True if the compiler is Intel")
    endif ()

    if ("${compilerID}" MATCHES Cray)
        _oph_set_ifndef (PLAT_CRAY_COMPILER_${language} 1 CACHE BOOL "True if the compiler is Cray")
        _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} "${compilerID}" CACHE STRING
                         "${doc_plat_compiler_type}")
    else ()
        _oph_set_ifndef (PLAT_CRAY_COMPILER_${language} 0 CACHE BOOL "True if the compiler is Cray")
    endif ()

    if ("${compilerID}" MATCHES ARM)
        _oph_set_ifndef (PLAT_ARM_COMPILER_${language} 1 CACHE BOOL "True if the compiler is ARM")
        _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} "${compilerID}" CACHE STRING
                         "${doc_plat_compiler_type}")
    else ()
        _oph_set_ifndef (PLAT_ARM_COMPILER_${language} 0 CACHE BOOL "True if the compiler is ARM")
    endif ()

    _oph_set_ifndef (PLAT_COMPILER_TYPE_${language} Unknown CACHE STRING
                     "${doc_plat_compiler_type}")

    set_property (CACHE PLAT_COMPILER_TYPE_${language}
                  PROPERTY STRINGS "Clang;AppleClang;GCC;MSVC;Intel;ARM;Cray;Unknown")

    unset (compilerID)
    unset (doc_plat_compiler_type)

    #

    set (doc_plat_big_endian "True if the target platform is big endian")
    set (doc_plat_little_endian "True if the target platform is little endian")

    if (CMAKE_${language}_BYTE_ORDER)
        _oph_set_ifndef (byte_order "${CMAKE_${language}_BYTE_ORDER}")

        if ("${byte_order}" STREQUAL BIG_ENDIAN)
            _oph_set_ifndef (PLAT_BIG_ENDIAN_${language} 1 CACHE BOOL "${doc_plat_big_endian}")
            _oph_set_ifndef (PLAT_LITTLE_ENDIAN_${language} 0 CACHE BOOL
                             "${doc_plat_little_endian}")
        elseif ("${byte_order}" STREQUAL LITTLE_ENDIAN)
            _oph_set_ifndef (PLAT_BIG_ENDIAN_${language} 0 CACHE BOOL "${doc_plat_big_endian}")
            _oph_set_ifndef (PLAT_LITTLE_ENDIAN_${language} 1 CACHE BOOL
                             "${doc_plat_little_endian}")
        endif ()

        unset (byte_order)
    endif ()

    if (NOT ((DEFINED PLAT_BIG_ENDIAN_${language}) OR (DEFINED CACHE{PLAT_BIG_ENDIAN_${language}}))
        AND ((DEFINED PLAT_LITTLE_ENDIAN_${language}) OR (DEFINED
                                                          CACHE{PLAT_LITTLE_ENDIAN_${language}})))
        if (CMAKE_CROSSCOMPILING)
            message (
                WARNING
                    "Cannot auto-detect endianness of current platform. Please fill the cache variables manually!"
                )
            _oph_set_ifndef (PLAT_BIG_ENDIAN_${language} 1 CACHE BOOL "${doc_plat_big_endian}")
            _oph_set_ifndef (PLAT_LITTLE_ENDIAN_${language} 0 CACHE BOOL
                             "${doc_plat_little_endian}")
        else ()
            try_run (is_big_endian compile_result "${CMAKE_CURRENT_BINARY_DIR}/check_endian"
                     "${CMAKE_CURRENT_LIST_DIR}/check_endian.cpp")

            unset (compile_result)

            if (is_big_endian)
                _oph_set_ifndef (PLAT_BIG_ENDIAN_${language} 1 CACHE BOOL "${doc_plat_big_endian}")
                _oph_set_ifndef (PLAT_LITTLE_ENDIAN_${language} 0 CACHE BOOL
                                 "${doc_plat_little_endian}")
            else ()
                _oph_set_ifndef (PLAT_BIG_ENDIAN_${language} 0 CACHE BOOL "${doc_plat_big_endian}")
                _oph_set_ifndef (PLAT_LITTLE_ENDIAN_${language} 1 CACHE BOOL
                                 "${doc_plat_little_endian}")
            endif ()

            unset (is_big_endian)
        endif ()
    endif ()

    unset (doc_plat_big_endian)
    unset (doc_plat_little_endian)

endfunction ()
