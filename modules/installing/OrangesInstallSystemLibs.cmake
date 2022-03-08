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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

#

option (ORANGES_IGNORE_SYSTEM_LIBS
		"Don't create install rules for compiler-provided system libraries" OFF)

mark_as_advanced (FORCE ORANGES_IGNORE_SYSTEM_LIBS)

if(ORANGES_IGNORE_SYSTEM_LIBS OR ${PROJECT_NAME}_SKIP_SYSTEM_LIBS_INSTALL)
	return ()
endif()

#

set (CMAKE_INSTALL_DEBUG_LIBRARIES TRUE)
set (CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS TRUE)

set (CMAKE_INSTALL_SYSTEM_LIBS_RUNTIME_COMPONENT ${PROJECT_NAME}_SystemLibraries)

include (InstallRequiredSystemLibraries)

set (CPACK_COMPONENT_SystemLibraries_DESCRIPTION "Installs all required system libraries")

set (CPACK_COMPONENT_SystemLibraries_GROUP Runtime)

set (CPACK_COMPONENT_GROUP_Runtime_DESCRIPTION
	 "Installs all available runtime artifacts and executables")
