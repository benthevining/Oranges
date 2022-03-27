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

OrangesFileUtils
-------------------------

General filesystem utilities.
This module provides the functions :command:`lemons_subdir_list()` and :command:`lemons_make_path_absolute()`.


Get a list of files and/or subdirectories in a directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: lemons_subdir_list

	lemons_subdir_list (DIR <directory> RESULT <out_var>
						[RECURSE] [FILES]
						[FULL_PATHS]|[BASE_DIR <baseDirectory>])

Returns a list of subdirectories within the specified directory.

`DIR` is required and must be the absolute path to the directory to be searched.
`RESULT` is required and is the name of the variable to which the resulting list will be set in the parent scope.

`RECURSE` is optional, and when present, the search will recurse into all levels of subdirectories.

If the `FILES` option is present, the function returns a list of files that are in the parent directory. If it is not present, the function returns a list of subdirectories that are in the parent directory.

If the `FULL_PATHS` option is present, the returned paths will be full absolute paths; otherwise, the `BASE_DIR` option must be specified and all paths will be calculated relative to that directory.


Make a path absolute, relative to a base directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command::lemons_make_path_absolute

	lemons_make_path_absolute (VAR <pathVariable>
							   [BASE_DIR <baseDirectory>])

`VAR` is the name of a variable that should be set to a path in the calling scope, and will also be used for the output in the calling scope.

If the path in `VAR` is not absolute, it will be made absolute, relative to BASE_DIR.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesCmakeDevTools)

function(lemons_subdir_list)

	oranges_add_function_message_context ()

	set (options RECURSE FILES FULL_PATHS)
	set (oneValueArgs RESULT DIR BASE_DIR)

	cmake_parse_arguments (LEMONS_SUBDIR "${options}" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_SUBDIR RESULT DIR)
	lemons_check_for_unparsed_args (LEMONS_SUBDIR)

	if((NOT LEMONS_SUBDIR_FULL_PATHS) AND (NOT LEMONS_SUBDIR_BASE_DIR))
		message (
			WARNING
				"Either FULL_PATHS or BASE_DIR must be specified in call to ${CMAKE_CURRENT_FUNCTION}!"
			)
	endif()

	cmake_path (IS_ABSOLUTE LEMONS_SUBDIR_DIR dir_path_is_absolute)

	if(dir_path_is_absolute)
		set (dir "${LEMONS_SUBDIR_DIR}")
	else()
		set (dir "${CMAKE_CURRENT_LIST_DIR}/${LEMONS_SUBDIR_DIR}")
	endif()

	lemons_make_variable_const (dir)

	if(LEMONS_SUBDIR_RECURSE)
		file (GLOB_RECURSE children RELATIVE ${dir} ${dir}/*)
	else()
		file (GLOB children RELATIVE ${dir} ${dir}/*)
	endif()

	set (dirlist "")

	foreach(child ${children})
		if(LEMONS_SUBDIR_FILES)
			set (filepath "${dir}/${child}")

			if(EXISTS ${filepath} AND NOT IS_DIRECTORY ${filepath} AND NOT "${child}" STREQUAL
																	   ".DS_Store")
				if(NOT LEMONS_SUBDIR_FULL_PATHS)
					cmake_path (RELATIVE_PATH filepath BASE_DIRECTORY "${LEMONS_SUBDIR_BASE_DIR}"
								OUTPUT_VARIABLE filepath)
				endif()

				list (APPEND dirlist "${filepath}")
			endif()
		else()
			set (dirpath "${dir}/${child}")

			if(EXISTS ${dirpath} AND IS_DIRECTORY ${dirpath})
				if(NOT LEMONS_SUBDIR_FULL_PATHS)
					cmake_path (RELATIVE_PATH dirpath BASE_DIRECTORY "${LEMONS_SUBDIR_BASE_DIR}"
								OUTPUT_VARIABLE dirpath)
				endif()

				list (APPEND dirlist "${dirpath}")
			endif()
		endif()
	endforeach()

	set (${LEMONS_SUBDIR_RESULT} ${dirlist} PARENT_SCOPE)

endfunction()

#

function(lemons_make_path_absolute)

	oranges_add_function_message_context ()

	set (oneValueArgs VAR BASE_DIR)

	cmake_parse_arguments (LEMONS_PATH "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_PATH VAR)
	lemons_check_for_unparsed_args (LEMONS_PATH)

	cmake_path (IS_ABSOLUTE ${LEMONS_PATH_VAR} is_abs_path)

	if(NOT is_abs_path)
		lemons_require_function_arguments (LEMONS_PATH BASE_DIR)

		set (${LEMONS_PATH_VAR} "${LEMONS_PATH_BASE_DIR}/${${LEMONS_PATH_VAR}}" PARENT_SCOPE)
	endif()

endfunction()
