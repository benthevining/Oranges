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

find_package (Python3 COMPONENTS Interpreter)
find_package (Doxygen REQUIRED dot)

if(NOT TARGET Python3::Interpreter OR NOT TARGET Doxygen::doxygen)
	message (WARNING "Doxygen dependencies missing!")
	return ()
endif()

#

# run python script...

#

add_custom_target (
	OrangesDoxygen
	COMMAND "${CMAKE_COMMAND}" -E make_directory "${PROJECT_SOURCE_DIR}/doc"
	COMMAND Doxygen::doxygen
	VERBATIM
	DEPENDS "${PROJECT_SOURCE_DIR}/Doxyfile"
	BYPRODUCTS "doc/html/index.html"
	WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
	COMMENT "Building Oranges documentation...")

add_custom_command (TARGET OrangesDoxygen PRE_BUILD COMMAND Doxygen::doxygen --version
					COMMENT "Doxygen version:")

set (docs_output_dir "${PROJECT_SOURCE_DIR}/doc")

set_target_properties (OrangesDoxygen PROPERTIES ADDITIONAL_CLEAN_FILES "${docs_output_dir}")

install (DIRECTORY "${docs_output_dir}/man3" TYPE MAN COMPONENT Oranges_Documentation
		 EXCLUDE_FROM_ALL OPTIONAL)

install (DIRECTORY "${docs_output_dir}/html" TYPE INFO COMPONENT Oranges_Documentation
		 EXCLUDE_FROM_ALL OPTIONAL)
