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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

oranges_file_scoped_message_context ("OrangesCTestConfig")

#

if(TARGET run_ctest)
	message (AUTHOR_WARNING "Target run_ctest already exists!")
	return ()
endif()

#

include (ProcessorCount)

ProcessorCount (num_procs)

if(NOT num_procs)
	set (num_procs 2)
endif()

set (CMAKE_CTEST_ARGUMENTS --parallel "${num_procs}")

unset (num_procs)

#

set (configured_file "")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/run_ctest.cmake" "${configured_file}" @ONLY)

add_custom_target (
	run_ctest COMMAND ctest -S "${configured_file}" -C $<CONFIG> -R "${PROJECT_NAME}."
					  --output-on-failure COMMENT "Running ctest..." COMMAND_ECHO STDOUT)

unset (configured_file)
