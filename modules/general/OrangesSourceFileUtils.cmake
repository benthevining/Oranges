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

OrangesSourceFileUtils
-------------------------

Utility function for adding source files to a target, and generating install rules for any header files.

Add source files to a target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_add_source_files

	oranges_add_source_files (TARGET <target>
							  DIRECTORY_NAME <directory>
							  FILES <filenames...>
							  [INSTALL_DIR <installBaseDir>]
							  [INSTALL_COMPONENT <component>])

This function adds the source files to the given target, and adds rules for any headers to be installed to `<installBaseDir>/<directory>`.

The variable `<directory>_files` will be set in the scope of the caller as a list of filenames, in the form `<directory>/<filename>`.

#]=======================================================================]


include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (GNUInstallDirs)
include (OrangesFunctionArgumentHelpers)

#

function(oranges_add_source_files)

	set (oneValueArgs DIRECTORY_NAME TARGET INSTALL_COMPONENT INSTALL_DIR)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "FILES" ${ARGN})

	oranges_assert_target_argument_is_target (ORANGES_ARG)
	lemons_require_function_arguments (ORANGES_ARG DIRECTORY_NAME FILES)

	foreach (filename IN LISTS ORANGES_ARG_FILES)
		target_sources ("${ORANGES_ARG_TARGET}" PRIVATE
			$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/${filename}>)
	endforeach()

	set (headers ${ORANGES_ARG_FILES})

	list (FILTER headers INCLUDE REGEX "\\.\\h")

	if(NOT ORANGES_ARG_INSTALL_DIR)
		set (ORANGES_ARG_INSTALL_DIR "${CMAKE_INSTALL_INCLUDEDIR}")
	endif()

	if(ORANGES_ARG_INSTALL_COMPONENT)
		set (install_component COMPONENT "${ORANGES_ARG_INSTALL_COMPONENT}")
	endif()

	install (FILES ${headers} DESTINATION "${ORANGES_ARG_INSTALL_DIR}/${ORANGES_ARG_DIRECTORY_NAME}"
			 ${install_component})

	foreach (header IN LISTS headers)
		target_sources ("${ORANGES_ARG_TARGET}" PRIVATE
			$<INSTALL_INTERFACE:${ORANGES_ARG_INSTALL_DIR}/${ORANGES_ARG_DIRECTORY_NAME}/${header}>)
	endforeach()

	list (TRANSFORM ORANGES_ARG_FILES PREPEND "${ORANGES_ARG_DIRECTORY_NAME}/")

	set (${ORANGES_ARG_DIRECTORY_NAME}_files ${ORANGES_ARG_FILES} PARENT_SCOPE)

endfunction()
