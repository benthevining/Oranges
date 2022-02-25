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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsJsonUtils)
include (LemonsFileUtils)

function(lemons_run_clean)

	set (oneValueArgs FILE DIR)

	cmake_parse_arguments (LEMONS_CLEAN "WIPE" "${oneValueArgs}" "" ${ARGN})

	if(NOT LEMONS_CLEAN_FILE)
		# from global config func...
		if(${PROJECT_NAME}_CONFIG_FILE)
			set (LEMONS_CLEAN_FILE ${${PROJECT_NAME}_CONFIG_FILE})

			if(NOT LEMONS_CLEAN_DIR)
				set (LEMONS_CLEAN_DIR ${PROJECT_SOURCE_DIR})
			endif()
		else()
			message (
				AUTHOR_WARNING
					"FILE not specified in call to ${CMAKE_CURRENT_FUNCTION}, either provide it in this call or call lemons_parse_project_configuration_file in this project first."
				)
		endif()
	endif()

	lemons_check_for_unparsed_args (LEMONS_CLEAN)

	if(NOT LEMONS_CLEAN_DIR)
		set (LEMONS_CLEAN_DIR ${CMAKE_CURRENT_SOURCE_DIR})
	endif()

	lemons_make_path_absolute (VAR LEMONS_CLEAN_FILE BASE_DIR ${LEMONS_CLEAN_DIR})

	file (READ ${LEMONS_CLEAN_FILE} file_contents)

	string (STRIP "${file_contents}" file_contents)

	string (JSON cleaningObj GET "${file_contents}" "Cleaning")

	lemons_json_array_to_list (TEXT "${cleaningObj}" ARRAY "clean" OUT cleanItems)

	if(cleanItems)
		foreach(item ${cleanItems})
			file (REMOVE_RECURSE "${LEMONS_CLEAN_DIR}/${item}")
		endforeach()
	endif()

	if(LEMONS_CLEAN_WIPE)
		lemons_json_array_to_list (TEXT "${cleaningObj}" ARRAY "wipe" OUT wipeItems)

		if(wipeItems)
			foreach(item ${wipeItems})
				file (REMOVE_RECURSE "${LEMONS_CLEAN_DIR}/${item}")
			endforeach()
		endif()
	endif()

endfunction()
