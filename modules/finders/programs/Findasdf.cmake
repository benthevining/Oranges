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

set_package_properties (asdf PROPERTIES URL "https://asdf-vm.com/"
						DESCRIPTION "Tool version manager")

#

oranges_file_scoped_message_context ("Findasdf")

#

set (asdf_FOUND FALSE)

find_program (ASDF_PROGRAM asdf)

mark_as_advanced (FORCE ASDF_PROGRAM)

if(ASDF_PROGRAM)
	add_executable (asdf IMPORTED GLOBAL)

	set_target_properties (asdf PROPERTIES IMPORTED_LOCATION "${ASDF_PROGRAM}")

	add_executable (asdf::asdf ALIAS asdf)

	set (asdf_FOUND TRUE)
else()
	find_package_warning_or_error ("asdf program cannot be found!")
endif()

#

function(asdf_install directory)
	oranges_add_function_message_context ()

	if(NOT TARGET asdf::asdf)
		message (FATAL_ERROR "asdf program cannot be found!")
	endif()

	execute_process (COMMAND asdf::asdf install WORKING_DIRECTORY "${directory}" COMMAND_ECHO
																  STDOUT)
endfunction()

#

function(asdf_update directory)
	oranges_add_function_message_context ()

	if(NOT TARGET asdf::asdf)
		message (FATAL_ERROR "asdf program cannot be found!")
	endif()

	execute_process (COMMAND asdf::asdf update WORKING_DIRECTORY "${directory}" COMMAND_ECHO STDOUT)
endfunction()
