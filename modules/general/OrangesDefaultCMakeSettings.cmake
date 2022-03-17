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

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#

set_property (GLOBAL PROPERTY REPORT_UNDEFINED_PROPERTIES
							  "${CMAKE_CURRENT_BINARY_DIR}/undefined_properties.log")

set_property (GLOBAL PROPERTY USE_FOLDERS YES)
set_property (GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "Targets")

#

# set (CMAKE_DEFAULT_BUILD_TYPE Release)

set (CMAKE_SUPPRESS_REGENERATION TRUE)

set (CMAKE_INCLUDE_CURRENT_DIR ON)

set (CMAKE_INSTALL_MESSAGE LAZY)

set (CMAKE_EXPORT_PACKAGE_REGISTRY ON)

set (CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION ON)

if(NOT APPLE)
	set (CMAKE_INSTALL_RPATH $ORIGIN)

	if(NOT WIN32)
		set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
		set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")
	endif()
endif()

if(IOS)
	set (CMAKE_OSX_DEPLOYMENT_TARGET 9.3)
else()
	set (CMAKE_OSX_DEPLOYMENT_TARGET 10.11)
endif()

set (CMAKE_COLOR_MAKEFILE ON)
set (CMAKE_VERBOSE_MAKEFILE ON)

#

include (ProcessorCount)

ProcessorCount (num_procs)

if(NOT num_procs)
	set (num_procs 2)
endif()

set (CMAKE_CTEST_ARGUMENTS --parallel "${num_procs}")

unset (num_procs)

#

set (CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
set (CMAKE_FOLDER "${PROJECT_NAME}")

#

include (LemonsDefaultProjectSettings)
