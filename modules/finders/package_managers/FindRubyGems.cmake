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

include (OrangesFindPackageHelpers)

set_package_properties (RubyGems PROPERTIES URL "https://guides.rubygems.org/"
						DESCRIPTION "Ruby package manager")

#

oranges_file_scoped_message_context ("FindRubyGems")

#

set (RubyGems_FOUND FALSE)

find_program (GEM_PROGRAM gem)

mark_as_advanced (FORCE GEM_PROGRAM)

if(GEM_PROGRAM)
	set (RubyGems_FOUND TRUE)

	add_executable (ruby_gem IMPORTED GLOBAL)

	set_target_properties (ruby_gem PROPERTIES IMPORTED_LOCATION "${GEM_PROGRAM}")

	add_executable (Ruby::gem ALIAS ruby_gem)
else()
	find_package_warning_or_error ("gem command cannot be found!")
endif()

#

function(ruby_update_all_gems)

	oranges_add_function_message_context ()

	if(NOT TARGET Ruby::gem)
		message (FATAL_ERROR "gem cannot be found!")
	endif()

	execute_process (COMMAND Ruby::gem update COMMAND_ECHO STDOUT)

endfunction()

#

function(ruby_install_gems)

	oranges_add_function_message_context ()

	if(NOT TARGET Ruby::gem)
		message (FATAL_ERROR "gem cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "GEMS" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG GEMS)

	if(ORANGES_ARG_UPDATE_FIRST)
		ruby_update_all_gems ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND Ruby::gem install ${ORANGES_ARG_PACKAGES} COMMAND_ECHO STDOUT
							 ${error_flag})

endfunction()
