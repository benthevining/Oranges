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

find_package (Python3 COMPONENTS Interpreter)

if(NOT TARGET Python3::Interpreter)
	message (WARNING "Python3 interpreter not found!")
	return ()
endif()

set (modules_output "${CMAKE_CURRENT_BINARY_DIR}/module_list.txt")

set (readme "${CMAKE_CURRENT_LIST_DIR}/../README.md")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/update_readme.py"
				"${CMAKE_CURRENT_BINARY_DIR}/update_readme.py" @ONLY NEWLINE_STYLE UNIX)

unset (readme)

add_custom_target (
	OrangesReadme
	COMMAND Python3::Interpreter "${CMAKE_CURRENT_LIST_DIR}/../help/help.py" --list-all-modules
			--output "${modules_output}"
	COMMAND Python3::Interpreter "${CMAKE_CURRENT_BINARY_DIR}/update_readme.py"
	COMMENT "Updating Oranges readme..."
	VERBATIM USES_TERMINAL)

set_property (TARGET OrangesReadme APPEND
		PROPERTY ADDITIONAL_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/update_readme.py")

set_target_properties (OrangesReadme PROPERTIES
	FOLDER Utility
	LABELS "Oranges;Utility"
	XCODE_GENERATE_SCHEME OFF
	EchoString "Updating Oranges ReadMe...")

unset (modules_output)

if(TARGET DependencyGraph)
	add_dependencies (OrangesReadme DependencyGraph)
endif()
