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
include (OrangesFetchRepository)
include (LemonsCmakeDevTools)

set_package_properties (pluginval PROPERTIES URL "https://github.com/Tracktion/pluginval"
						DESCRIPTION "Audio plugin testing and validation tool")

set (pluginval_FOUND FALSE)

find_program (PLUGINVAL_PROGRAM pluginval)

mark_as_advanced (FORCE PLUGINVAL_PROGRAM)

if(PLUGINVAL_PROGRAM)

	add_executable (pluginval IMPORTED GLOBAL)

	set_target_properties (pluginval PROPERTIES IMPORTED_LOCATION "${PLUGINVAL_PROGRAM}")

	add_executable (Tracktion::pluginval ALIAS pluginval)

	set (pluginval_FOUND TRUE)

else()

	option (PLUGINVAL_BUILD_AT_CONFIGURE_TIME ON
			"Build pluginval from source at configure-time if it can't be found on the system")

	if(PLUGINVAL_BUILD_AT_CONFIGURE_TIME)

		oranges_fetch_repository (
			NAME
			pluginval
			GITHUB_REPOSITORY
			Tracktion/pluginval
			GIT_TAG
			origin/master
			DOWNLOAD_ONLY
			EXCLUDE_FROM_ALL
			NEVER_LOCAL)

		if(APPLE)
			execute_process (COMMAND "${pluginval_SOURCE_DIR}/install/mac_build")
		elseif(WIN32)
			execute_process (COMMAND "${pluginval_SOURCE_DIR}/install/windows_build.bat")
		else()
			execute_process (COMMAND "${pluginval_SOURCE_DIR}/install/linux_build")
		endif()

		unset (CACHE{PLUGINVAL_BUILT_PROGRAM})

		find_program (PLUGINVAL_BUILT_PROGRAM pluginval PATHS "${pluginval_SOURCE_DIR}/bin")

		if(PLUGINVAL_BUILT_PROGRAM)
			add_executable (pluginval IMPORTED GLOBAL)

			set_target_properties (pluginval PROPERTIES IMPORTED_LOCATION
														"${PLUGINVAL_BUILT_PROGRAM}")

			add_executable (Tracktion::pluginval ALIAS pluginval)

			set (pluginval_FOUND TRUE)
		endif()
	endif()
endif()

# #########################################################################################################

function(pluginval_add_plugin_test)

	if(NOT TARGET Tracktion::pluginval)
		message (WARNING "pluginval not found, cannot add tests!")
		return ()
	endif()

	set (options NO_GUI VERBOSE RANDOMIZE)
	set (oneValueArgs TARGET NAME LEVEL LOG_DIR REPEATS)
	set (multiValueArgs SAMPLERATES BLOCKSIZES)

	cmake_parse_arguments (ORANGES_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_NAME)
		set (ORANGES_ARG_NAME "${ORANGES_ARG_TARGET}.pluginval")
	endif()

	#

	if(NOT ORANGES_ARG_LEVEL)
		set (ORANGES_ARG_LEVEL 5)
	endif()

	set (PLUGINVAL_LEVEL "${ORANGES_ARG_LEVEL}" CACHE STRING "Pluginval testing intensity level")

	set_property (CACHE PLUGINVAL_LEVEL PROPERTY STRINGS "1;2;3;4;5;6;7;8;9;10")

	#

	if(ORANGES_ARG_VERBOSE)
		set (PLUGINVAL_VERBOSE TRUE CACHE BOOL "Enable verbose testing output")
	else()
		set (PLUGINVAL_VERBOSE FALSE CACHE BOOL "Enable verbose testing output")
	endif()

	if(PLUGINVAL_VERBOSE)
		set (verbose_flag --verbose)
	endif()

	#

	set (PLUGINVAL_SAMPLERATES "${ORANGES_ARG_SAMPLERATES}" CACHE STRING "Testing samplerates")

	list (JOIN "${PLUGINVAL_SAMPLERATES}" "," sr_list)

	if(sr_list)
		set (samplerates_flag --sample-rates "${sr_list}")
	endif()

	#

	set (PLUGINVAL_BLOCKSIZES "${ORANGES_ARG_BLOCKSIZES}" CACHE STRING "Testing blocksizes")

	list (JOIN "${ORANGES_ARG_BLOCKSIZES}" "," blk_list)

	if(blk_list)
		set (blocksizes_flag --block-sizes "${blk_list}")
	endif()

	#

	if(ORANGES_ARG_NO_GUI)
		set (PLUGINVAL_DISABLE_GUI TRUE CACHE BOOL "Disable GUI tests")
	else()
		set (PLUGINVAL_DISABLE_GUI FALSE CACHE BOOL "Disable GUI tests")
	endif()

	if(PLUGINVAL_DISABLE_GUI)
		set (no_gui_flag --skip-gui-tests)
	endif()

	#

	if(ORANGES_ARG_LOG_DIR)
		set (log_dir_flag --output-dir "${ORANGES_ARG_LOG_DIR}")
	endif()

	if(ORANGES_ARG_REPEATS)
		set (repeats_flag --repeat "${ORANGES_ARG_REPEATS}")
	endif()

	if(ORANGES_ARG_RANDOMIZE)
		set (random_flag --randomise)
	endif()

	add_test (
		NAME "${ORANGES_ARG_NAME}"
		COMMAND
			Tracktion::pluginval --strictness-level "${PLUGINVAL_LEVEL}" --validate
			$<TARGET_PROPERTY:${ORANGES_ARG_TARGET},JUCE_PLUGIN_ARTEFACT_FILE> ${no_gui_flag}
			${log_dir_flag} ${verbose_flag} ${samplerates_flag} ${blocksizes_flag} ${repeats_flag}
			${random_flag})

endfunction()
