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

OrangesInstallSystemLibs
-------------------------

When this modules is included, it configures installation of system libraries, unless the ``ORANGES_IGNORE_SYSTEM_LIBS`` option is set to ON.

Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable::ORANGES_IGNORE_SYSTEM_LIBS

If set to ``ON``, including this module will do nothing. Defaults to ``OFF``.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (CPackComponent)

#

option (ORANGES_IGNORE_SYSTEM_LIBS
        "Don't create install rules for compiler-provided system libraries" OFF)

mark_as_advanced (FORCE ORANGES_IGNORE_SYSTEM_LIBS)

if (ORANGES_IGNORE_SYSTEM_LIBS)
    return ()
endif ()

#

set (CMAKE_INSTALL_DEBUG_LIBRARIES TRUE)
set (CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS TRUE)

set (CMAKE_INSTALL_SYSTEM_LIBS_RUNTIME_COMPONENT SystemLibraries)

include (InstallRequiredSystemLibraries)

cpack_add_component (
    SystemLibraries
    DISPLAY_NAME "System libraries"
    DESCRIPTION "Installs all required system libraries"
    INSTALL_TYPES Developer
    DISABLED)
