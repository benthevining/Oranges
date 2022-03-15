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

include (FeatureSummary)
include (LemonsCmakeDevTools)

set_package_properties (Homebrew PROPERTIES URL "https://brew.sh/"
						DESCRIPTION "MacOS package manager")

set (Homebrew_FOUND FALSE)

find_program (HOMEBREW brew)

if(NOT HOMEBREW)
	unset (CACHE{HOMEBREW})

	find_program (BASH bash)

	if(Homebrew_FIND_REQUIRED AND NOT BASH)
		message (FATAL_ERROR "bash is required for installing Homebrew, and cannot be found!")
	endif()

	if(NOT Homebrew_FIND_QUIETLY)
		message (STATUS "Installing Homebrew...")
	endif()

	execute_process (COMMAND "${BASH}" "${CMAKE_CURRENT_LIST_DIR}/scripts/mac_install_homebrew.sh"
							 COMMAND_ERROR_IS_FATAL ANY)

	find_program (HOMEBREW brew)

	if(Homebrew_FIND_REQUIRED AND NOT HOMEBREW)
		message (FATAL_ERROR "Error installing Homebrew!")
	endif()
endif()

mark_as_advanced (FORCE HOMEBREW BASH)

if(HOMEBREW)
	set (Homebrew_FOUND TRUE)

	add_executable (Homebrew IMPORTED GLOBAL)

	set_target_properties (Homebrew PROPERTIES IMPORTED_LOCATION "${HOMEBREW}")

	add_executable (Homebrew::Homebrew ALIAS Homebrew)
endif()

#

function(homebrew_update_all)

	if(NOT TARGET Homebrew::Homebrew)
		message (FATAL_ERROR "Homebrew cannot be found!")
	endif()

	execute_process (COMMAND Homebrew::Homebrew update COMMAND_ECHO STDOUT)

	execute_process (COMMAND Homebrew::Homebrew upgrade COMMAND_ECHO STDOUT)

endfunction()

#

function(homebrew_install_packages)

	if(NOT TARGET Homebrew::Homebrew)
		message (FATAL_ERROR "Homebrew cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "PACKAGES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	if(ORANGES_ARG_UPDATE_FIRST)
		homebrew_update_all ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND Homebrew::Homebrew install ${ORANGES_ARG_PACKAGES} COMMAND_ECHO STDOUT
							 ${error_flag})

endfunction()
