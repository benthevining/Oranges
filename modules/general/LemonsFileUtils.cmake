# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

#[[
General filesystem utilities.

## Function:

### lemons_subdir_list
```
lemons_subdir_list (DIR <directory> RESULT <out_var>
					[RECURSE] [FILES] [FULL_PATHS])
```
Returns a list of subdirectories within the specified directory.

`DIR` is required and must be the absolute path to the directory to be searched.
`RESULT` is required and is the name of the variable to which the resulting list will be set in the parent scope.

`RECURSE` is optional, and when present, the search will recurse into all levels of subdirectories.

If the `FILES` flag is present, the function returns a list of files that are in the parent directory. If it is not present, the function returns a list of subdirectories that are in the parent directory.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)

function(lemons_subdir_list)

	set (options RECURSE FILES FULL_PATHS)
	set (oneValueArgs RESULT DIR)

	cmake_parse_arguments (LEMONS_SUBDIR "${options}" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_SUBDIR RESULT DIR)
	lemons_check_for_unparsed_args (LEMONS_SUBDIR)

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
				if(LEMONS_SUBDIR_FULL_PATHS)
					list (APPEND dirlist "${filepath}")
				else()
					list (APPEND dirlist "${child}")
				endif()
			endif()
		else()
			set (dirpath "${dir}/${child}")

			if(EXISTS ${dirpath} AND IS_DIRECTORY ${dirpath})
				if(LEMONS_SUBDIR_FULL_PATHS)
					list (APPEND dirlist "${dirpath}")
				else()
					list (APPEND dirlist "${child}")
				endif()
			endif()
		endif()
	endforeach()

	set (${LEMONS_SUBDIR_RESULT} ${dirlist} PARENT_SCOPE)

endfunction()

#

function(lemons_make_path_absolute)

	set (oneValueArgs VAR BASE_DIR)

	cmake_parse_arguments (LEMONS_PATH "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (LEMONS_PATH VAR BASE_DIR)
	lemons_check_for_unparsed_args (LEMONS_PATH)

	cmake_path (IS_ABSOLUTE ${LEMONS_PATH_VAR} is_abs_path)

	if(NOT is_abs_path)
		set (${LEMONS_PATH_VAR} "${LEMONS_PATH_BASE_DIR}/${${LEMONS_PATH_VAR}}" PARENT_SCOPE)
	endif()

endfunction()
