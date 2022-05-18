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

LinuxLSBInfo
-------------------------

This module sets some cache variables identifying the Linux distribution of the host computer.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: PROGRAM_LSB_RELEASE

The path to the ``lsb_release`` program.

.. cmake:variable:: LSB_DISTRIBUTOR_ID

LSB distributor ID for your Linux distribution. Initialized with the output of executing ``<PROGRAM_LSB_RELEASE> -si``.

.. cmake:variable:: LSB_RELEASE

LSB release for your Linux distribution. Initialized with the output of executing ``<PROGRAM_LSB_RELEASE> -sr``.

.. cmake:variable:: LSB_CODENAME

LSB codename for your Linux distribution. Initialized with the output of running ``<PROGRAM_LSB_RELEASE> -sc``.

#]=======================================================================]

include_guard (GLOBAL)

if ((DEFINED LSB_DISTRIBUTOR_ID OR DEFINED CACHE{LSB_DISTRIBUTOR_ID})
    AND (DEFINED LSB_RELEASE OR DEFINED CACHE{LSB_RELEASE}) AND (DEFINED LSB_CODENAME
                                                                 OR DEFINED CACHE{LSB_CODENAME}))
    return ()
endif ()

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("LinuxLSBInfo")

find_program (PROGRAM_LSB_RELEASE lsb_release DOC "LSB release executable for your Linux distro")

mark_as_advanced (FORCE PROGRAM_LSB_RELEASE)

if (NOT PROGRAM_LSB_RELEASE)

    message (AUTHOR_WARNING "Unable to detect LSB info for your Linux distro")

    set (LSB_DISTRIBUTOR_ID "unknown" CACHE STRING "LSB distributor ID for your Linux distribution")
    set (LSB_RELEASE "unknown" CACHE STRING "LSB executable for your Linux distribution")
    set (LSB_CODENAME "unknown" CACHE STRING "LSB codename for your Linux distribution")

    return ()
endif ()

execute_process (COMMAND "${PROGRAM_LSB_RELEASE}" -sc OUTPUT_VARIABLE LSB_CODENAME
                 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND "${PROGRAM_LSB_RELEASE}" -sr OUTPUT_VARIABLE lsb_rel
                 OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process (COMMAND "${PROGRAM_LSB_RELEASE}" -si OUTPUT_VARIABLE lsb_distrib_id
                 OUTPUT_STRIP_TRAILING_WHITESPACE)

set (LSB_DISTRIBUTOR_ID "${lsb_distrib_id}" CACHE STRING
                                                  "LSB distributor ID for your Linux distribution")

set (LSB_RELEASE "${lsb_rel}" CACHE STRING "LSB release for your Linux distribution")

set (LSB_CODENAME "${LSB_CODENAME}" CACHE STRING "LSB codename for your Linux distribution")

unset (lsb_distrib_id)
unset (lsb_rel)

message (DEBUG "Linux ditributor ID: ${LSB_DISTRIBUTOR_ID}")
message (DEBUG "Linux release ID: ${LSB_RELEASE}")
message (DEBUG "Linux release codename: ${LSB_CODENAME}")

mark_as_advanced (FORCE LSB_DISTRIBUTOR_ID LSB_RELEASE LSB_CODENAME)
