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

Findusb
-----------------

A find module for the libusb library.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``usb::usb``

The libusb library.


Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: USB_INCLUDE_DIR

Include directory path for libusb.
When searching for this path, the environment variable :envvar:`USB_INCLUDE_DIR` is added to the search path.


.. cmake:variable:: USB_LIBRARY

Path to the prebuilt binary of the libusb library.
When searching for this file, the environment variable :envvar:`USB_LIBRARY` is added to the search path.


Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: USB_INCLUDE_DIR

This environment variable, if set, is added to the search path when locating the :variable:`USB_INCLUDE_DIR` path.


.. cmake:envvar:: USB_LIBRARY

This environment variable, if set, is added to the search path when locating the :variable:`USB_LIBRARY` path.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties ("${CMAKE_FIND_PACKAGE_NAME}" PROPERTIES URL "https://libusb.info/"
                        DESCRIPTION "USB library")

find_package (PkgConfig QUIET)

if (PKG_CONFIG_FOUND)
    pkg_search_module (PKGUSB QUIET usb libusb)
endif ()

find_path (USB_INCLUDE_DIR NAMES libusb.h PATHS ${PKGUSB_INCLUDE_DIRS} ENV USB_INCLUDE_DIR
           DOC "libusb include directories")

find_library (USB_LIBRARY NAMES usb libusb PATHS ${PKGUSB_LIBRARY_DIRS} ENV USB_LIBRARY
              DOC "libusb library")

mark_as_advanced (USB_INCLUDE_DIR USB_LIBRARY)

if (PKGUSB_VERSION)
    set (version_flag VERSION_VAR PKGUSB_VERSION HANDLE_VERSION_RANGE)
else ()
    unset (version_flag)
endif ()

find_package_handle_standard_args ("${CMAKE_FIND_PACKAGE_NAME}"
                                   REQUIRED_VARS USB_INCLUDE_DIR USB_LIBRARY ${version_flag})

if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
    return ()
endif ()

add_library (usb::usb IMPORTED UNKNOWN)

set_target_properties (usb::usb PROPERTIES IMPORTED_LOCATION "${USB_LIBRARY}")

target_include_directories (usb::usb INTERFACE "${USB_INCLUDE_DIR}")

find_package_detect_macos_arch (usb::usb "${USB_LIBRARY}")

target_sources (usb::usb INTERFACE "${USB_INCLUDE_DIR}/libusb.h")

find_package_message ("${CMAKE_FIND_PACKAGE_NAME}" "libusb - found (local)"
                      "[${USB_INCLUDE_DIR}] [${USB_LIBRARY}]")
