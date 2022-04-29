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

cmake_minimum_required (VERSION 3.13 FATAL_ERROR)

project (
	OrangesHelp
	VERSION "${Oranges_VERSION}"
	DESCRIPTION "Oranges CLI help"
	HOMEPAGE_URL "${Oranges_HOMEPAGE_URL}"
	LANGUAGES NONE)

find_package (Python3 3.9 COMPONENTS Interpreter)

if (NOT TARGET Python3::Interpreter OR NOT Python3_FOUND)
	if (Oranges_IS_TOP_LEVEL)
		message (
			WARNING "Python cannot be found, CLI help tool cannot be generated!"
			)
	endif ()

	return ()
endif ()

set (help_dir "${CMAKE_CURRENT_LIST_DIR}/oranges_help")

add_custom_target (
	OrangesHelp
	COMMAND Python3::Interpreter -m build
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
	COMMENT "Building Oranges CLI help tool..."
	DEPENDS # cmake-format: sortable
			"${CMAKE_CURRENT_LIST_DIR}/pyproject.toml"
	SOURCES # cmake-format: sortable
			"${CMAKE_CURRENT_LIST_DIR}/help.py"
			"${help_dir}/commands.py"
			"${help_dir}/doc_block.py"
			"${help_dir}/main.py"
			"${help_dir}/modules.py"
			"${help_dir}/paths.py"
			"${help_dir}/printing.py"
			"${help_dir}/properties.py"
			"${help_dir}/targets.py"
	VERBATIM USES_TERMINAL)

set_target_properties (OrangesHelp PROPERTIES FOLDER Oranges LABELS
															 "Oranges;docs")

unset (all_flag)

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
			 "${CMAKE_CURRENT_LIST_DIR}/build/"
			 "${CMAKE_CURRENT_LIST_DIR}/dist/"
			 "${CMAKE_CURRENT_LIST_DIR}/oranges_help.egg-info"
			 "${CMAKE_CURRENT_LIST_DIR}/__pycache__"
			 "${CMAKE_CURRENT_LIST_DIR}/oranges_help/__pycache__"
			 "${CMAKE_CURRENT_LIST_DIR}/setup.cfg")
