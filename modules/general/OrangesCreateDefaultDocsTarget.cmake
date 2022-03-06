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

find_package (Doxygen COMPONENTS dot)

if(NOT TARGET Doxygen::doxygen)
	message (WARNING "Doxygen dependencies missing!")

	function(oranges_create_default_docs_target)

	endfunction()

	return ()
endif()

include (LemonsCmakeDevTools)

#

function(oranges_create_default_docs_target)

	set (oneValueArgs TARGET PROJECT)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET PROJECT)

	add_custom_target (
		"${ORANGES_ARG_TARGET}"
		COMMAND "${CMAKE_COMMAND}" -E make_directory "${PROJECT_SOURCE_DIR}/doc"
		COMMAND Doxygen::doxygen
		VERBATIM
		DEPENDS "${PROJECT_SOURCE_DIR}/Doxyfile"
		BYPRODUCTS "${PROJECT_SOURCE_DIR}/doc/html/index.html"
		WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
		COMMENT "Building ${ORANGES_ARG_PROJECT} documentation...")

	add_custom_command (TARGET "${ORANGES_ARG_TARGET}" PRE_BUILD COMMAND Doxygen::doxygen --version
						COMMENT "Doxygen version:")

	set (docs_output_dir "${PROJECT_SOURCE_DIR}/doc")

	set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES ADDITIONAL_CLEAN_FILES
															  "${docs_output_dir}")

	install (DIRECTORY "${docs_output_dir}/man3" TYPE MAN
			 COMPONENT "${ORANGES_ARG_PROJECT}_Documentation" EXCLUDE_FROM_ALL OPTIONAL)

	install (DIRECTORY "${docs_output_dir}/html" TYPE INFO
			 COMPONENT "${ORANGES_ARG_PROJECT}_Documentation" EXCLUDE_FROM_ALL OPTIONAL)

endfunction()
