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

#[[

- add properties
- fix path handling for installed version
- install manifest

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.13 FATAL_ERROR)

project (
	OrangesHelp
	VERSION "${Oranges_VERSION}"
	DESCRIPTION "Oranges CLI help"
	HOMEPAGE_URL "${Oranges_HOMEPAGE_URL}"
	LANGUAGES NONE)

find_package (Python3 3.9 COMPONENTS Interpreter)

if (NOT TARGET Python3::Interpreter)
	if (Oranges_IS_TOP_LEVEL)
		message (
			WARNING "Python cannot be found, CLI help tool cannot be generated!"
			)
	endif ()

	return ()
endif ()

set (help_dir "${CMAKE_CURRENT_LIST_DIR}/oranges_help")

set (PATHS_OUTPUT_FILE "${help_dir}/data/modules_root.txt")

file (WRITE "${PATHS_OUTPUT_FILE}" "${CMAKE_CURRENT_LIST_DIR}/../modules")

set (input_script "${CMAKE_CURRENT_LIST_DIR}/scripts/install_help.cmake")

if (Oranges_IS_TOP_LEVEL)
	set (all_flag ALL)
endif ()

# This target runs the actual build of the python package
add_custom_target (
	OrangesHelp
	${all_flag}
	COMMAND python3 -m build
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
	COMMENT "Building Oranges CLI help tool..."
	DEPENDS # cmake-format: sortable
			"${CMAKE_CURRENT_LIST_DIR}/pyproject.toml" "${input_script}"
	SOURCES # cmake-format: sortable
			"${CMAKE_CURRENT_LIST_DIR}/help.py"
			"${help_dir}/commands.py"
			"${help_dir}/doc_block.py"
			"${help_dir}/main.py"
			"${help_dir}/modules.py"
			"${help_dir}/paths.py"
			"${help_dir}/printing.py"
			"${help_dir}/targets.py"
	VERBATIM USES_TERMINAL)

unset (all_flag)

#
# This pre-build step re-sets the data/modules_root.txt file to contain the path
# to the modules in the build/source tree

set (configured_build_script "${CMAKE_CURRENT_BINARY_DIR}/pre_build.cmake")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/pre_build.cmake"
				"${configured_build_script}" @ONLY NEWLINE_STYLE UNIX)

add_custom_command (
	TARGET OrangesHelp
	PRE_BUILD
	COMMAND "${CMAKE_COMMAND}" -P "${configured_build_script}"
	BYPRODUCTS "${PATHS_OUTPUT_FILE}"
	VERBATIM USES_TERMINAL
	COMMENT "OrangesHelp pre-build step...")

#
# Running the python build seems to mess with source file permissions, so this
# post-build step restores all of them

set (configured_post_build "${CMAKE_CURRENT_BINARY_DIR}/post_build.cmake")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/post_build.cmake"
				"${configured_post_build}" @ONLY NEWLINE_STYLE UNIX)

find_program (PROGRAM_SUDO NAMES sudo DOC "Sudo program")

if (PROGRAM_SUDO)
	set (sudo "${PROGRAM_SUDO}")
endif ()

# add_custom_command ( TARGET OrangesHelp POST_BUILD COMMAND ${sudo}
# "${CMAKE_COMMAND}" -P "${configured_post_build}" VERBATIM USES_TERMINAL
# COMMENT "Restoring source tree permissions...")

#
# This install rule runs pip install on the built package This executes a script
# at install-time, with the CMAKE_INSTALL_PREFIX passed in.

set (configured_script "${CMAKE_CURRENT_BINARY_DIR}/install_help.cmake")

configure_file ("${input_script}" "${configured_script}" @ONLY
				NEWLINE_STYLE UNIX)

install (SCRIPT "${configured_script}" COMPONENT oranges_help)

set (properties_json "${help_dir}/data/properties.json")

set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
			  PROPERTY CMAKE_CONFIGURE_DEPENDS "${properties_json}")

set_property (
	TARGET OrangesHelp
	APPEND
	PROPERTY ADDITIONAL_CLEAN_FILES
			 # cmake-format: sortable
			 "${properties_json}"
			 "${help_dir}/oranges_help.egg-info"
			 "${CMAKE_CURRENT_LIST_DIR}/build"
			 "${CMAKE_CURRENT_LIST_DIR}/dist"
			 "${CMAKE_CURRENT_LIST_DIR}/oranges_help.egg-info"
			 "${CMAKE_CURRENT_LIST_DIR}/__pycache__"
			 "${CMAKE_CURRENT_LIST_DIR}/oranges_help/__pycache__"
			 "${CMAKE_CURRENT_LIST_DIR}/setup.cfg"
			 "${PATHS_OUTPUT_FILE}")
