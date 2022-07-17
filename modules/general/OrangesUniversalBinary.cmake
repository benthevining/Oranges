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

OrangesUniversalBinary
-----------------------

Provides a function for enabling a MacOS universal binary.

.. command:: oranges_enable_universal_binary

    ::

        oranges_enable_universal_binary (<target>)

Enables building the specified ``<target>`` as a MacOS universal binary, if :variable:`ORANGES_DISABLE_UNIVERSAL_BINARY` is not ON.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: ORANGES_DISABLE_UNIVERSAL_BINARY

If true, this disables MacOS universal binaries, and calling :command:`oranges_enable_universal_binary` does nothing.


Target properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``ORANGES_MAC_UNIVERSAL_BINARY``

If true, this target is being built as a MacOSX universal binary.
This property will (probably) be undefined for any target that was not passed to a :command:`oranges_enable_universal_binary` call.


Global properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``ORANGES_MAC_NATIVE_ARCH``

On Mac systems, this is a string describing the host's native architecture (typically arm64 or x86_64).
This property is defined by inclusion of the :doc:`OrangesUniversalBinary` module.
Undefined on non-Apple systems, or when crosscompiling for iOS.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesGeneratePlatformHeader)

option (ORANGES_DISABLE_UNIVERSAL_BINARY "Disables building MacOS universal binaries" OFF)

define_property (
    TARGET INHERITED
    PROPERTY ORANGES_MAC_UNIVERSAL_BINARY
    BRIEF_DOCS "TRUE if building a universal binary; otherwise FALSE"
    FULL_DOCS
        "When TRUE, the OSX architectures have been set to x86_64 and arm64; when false, it has been set to only this Mac's native architecture. FALSE on non-MacOSX platforms."
    )

define_property (
    GLOBAL
    PROPERTY ORANGES_MAC_NATIVE_ARCH
    BRIEF_DOCS
        "String describing this Mac's native processor architecture; either x86_64 (Intel) or arm64 (M1)"
    FULL_DOCS
        "String describing this Mac's native processor architecture; either x86_64 (Intel) or arm64 (M1). Undefined on non-MacOSX platforms."
    )

#

set (__ORANGES_MAC_UNIV_BIN OFF CACHE INTERNAL "")

if (PLAT_MACOSX)

    execute_process (COMMAND uname -m OUTPUT_VARIABLE osx_native_arch
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

    message (VERBOSE "Mac native arch: ${osx_native_arch}")

    set_property (GLOBAL PROPERTY ORANGES_MAC_NATIVE_ARCH "${osx_native_arch}")

    # cmake-format: off
    if ( ("${osx_native_arch}" STREQUAL "arm64")
        AND XCODE
        AND ("${CMAKE_${PLAT_DEFAULT_TESTING_LANGUAGE}_COMPILER_ID}" MATCHES "Clang") )
    # cmake-format: on

        set (__ORANGES_MAC_UNIV_BIN ON CACHE INTERNAL "")
    endif ()

    unset (osx_native_arch)

endif ()

#

function (oranges_enable_universal_binary target)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target '${target}' does not exist!")
    endif ()

    set_property (TARGET "${target}" APPEND PROPERTY EXPORT_PROPERTIES ORANGES_MAC_UNIVERSAL_BINARY)

    if (__ORANGES_MAC_UNIV_BIN AND NOT ORANGES_DISABLE_UNIVERSAL_BINARY)
        set_target_properties (
            "${target}"
            PROPERTIES $<$<PLATFORM_ID:Darwin>:OSX_ARCHITECTURES x86_64$<SEMICOLON>arm64>
                       $<$<PLATFORM_ID:Darwin>:ORANGES_MAC_UNIVERSAL_BINARY TRUE>
                       $<<NOT:$<PLATFORM_ID:Darwin>>:ORANGES_MAC_UNIVERSAL_BINARY FALSE>)

        message (VERBOSE "Enabling Mac universal binary for target ${target}")
    else ()
        set_target_properties (
            "${target}" PROPERTIES $<$<PLATFORM_ID:Darwin>:OSX_ARCHITECTURES ${osx_native_arch}>
                                   ORANGES_MAC_UNIVERSAL_BINARY FALSE)

        message (VERBOSE "Mac universal binary disabled for target ${target}")
    endif ()

endfunction ()
