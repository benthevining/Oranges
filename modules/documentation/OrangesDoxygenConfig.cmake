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

This module provides the function oranges_create_doxygen_target().

Inclusion style: Once globally

## Functions:

### oranges_create_doxygen_target
```
oranges_create_doxygen_target (INPUT_PATHS <inputPaths>
							   [TARGET <docsTargetName>]
							   [OUTPUT_DIR <docsOutputDir>]
							   [MAIN_PAGE_MD_FILE <mainPageFile>]
							   [LOGO <logoFile>]
							   [FILE_PATTERNS <filePatterns>]
							   [IMAGE_PATHS <imagePaths>]
							   [NO_VERSION_DISPLAY])
```

Creates a target to execute Doxygen.

The only required argument is the INPUT_PATHS.
TARGET defaults to ${PROJECT_NAME}Doxygen.
OUTPUT_DIR defaults to ${PROJECT_SOURCE_DIR}/doc.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)
include (LemonsFileUtils)

set (ORANGES_DOXYFILE_INPUT "${CMAKE_CURRENT_LIST_DIR}/scripts/Doxyfile" CACHE INTERNAL "")
set (ORANGES_DOXYLAYOUT_INPUT "${CMAKE_CURRENT_LIST_DIR}/scripts/DoxygenLayout.xml" CACHE INTERNAL
																						  "")

#

find_package (Doxygen OPTIONAL_COMPONENTS dot)

if(NOT TARGET Doxygen::doxygen)
	message (WARNING "Doxygen dependencies missing!")

	function(oranges_create_doxygen_target)

	endfunction()

	return ()
endif()

#

function(oranges_create_doxygen_target)

	set (oneValueArgs TARGET MAIN_PAGE_MD_FILE LOGO OUTPUT_DIR)
	set (multiValueArgs INPUT_PATHS FILE_PATTERNS IMAGE_PATHS)

	cmake_parse_arguments (ORANGES_ARG "NO_VERSION_DISPLAY" "${oneValueArgs}" "${multiValueArgs}"
						   ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG INPUT_PATHS)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	foreach(input_path ${ORANGES_ARG_INPUT_PATHS})
		lemons_make_path_absolute (VAR input_path BASE_DIR "${PROJECT_SOURCE_DIR}")

		list (APPEND ORANGES_DOXYGEN_INPUT_PATHS "${input_path}")
	endforeach()

	list (REMOVE_DUPLICATES ORANGES_DOXYGEN_INPUT_PATHS)
	list (JOIN ORANGES_DOXYGEN_INPUT_PATHS " " ORANGES_DOXYGEN_INPUT_PATHS)

	if(ORANGES_ARG_MAIN_PAGE_MD_FILE)
		lemons_make_path_absolute (VAR ORANGES_ARG_MAIN_PAGE_MD_FILE BASE_DIR
								   "${PROJECT_SOURCE_DIR}")

		if(EXISTS "${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
			set (ORANGES_DOXYGEN_MAIN_PAGE_MARKDOWN_FILE "${ORANGES_ARG_MAIN_PAGE_MD_FILE}")
		else()
			message (
				AUTHOR_WARNING
					"Specified Doxygen main page markdown file ${ORANGES_ARG_MAIN_PAGE_MD_FILE} does not exist!"
				)
		endif()
	else()
		find_file (
			ORANGES_DOCS_README README.md README PATHS "${PROJECT_SOURCE_DIR}"
													   ${ORANGES_DOXYGEN_INPUT_PATHS} NO_CACHE
			NO_DEFAULT_PATH)

		if(ORANGES_DOCS_README)
			set (ORANGES_ARG_MAIN_PAGE_MD_FILE "${ORANGES_DOCS_README}")
		endif()
	endif()

	if(ORANGES_ARG_LOGO)
		lemons_make_path_absolute (VAR ORANGES_ARG_LOGO BASE_DIR "${PROJECT_SOURCE_DIR}")

		if(EXISTS "${ORANGES_ARG_LOGO}")
			set (ORANGES_DOXYGEN_LOGO "${ORANGES_ARG_LOGO}")
		else()
			message (
				AUTHOR_WARNING "Specified Doxygen logo file ${ORANGES_DOXYGEN_LOGO} does not exist!"
				)
		endif()
	endif()

	if(NOT ORANGES_ARG_FILE_PATTERNS)
		set (ORANGES_DOXYGEN_INPUT_FILE_PATTERNS "*.h")
	endif()

	if(ORANGES_ARG_MAIN_PAGE_MD_FILE)
		list (APPEND ORANGES_ARG_FILE_PATTERNS *.md)
	endif()

	if(ORANGES_ARG_OUTPUT_DIR)
		set (ORANGES_DOC_OUTPUT_DIR "${ORANGES_ARG_OUTPUT_DIR}")
	else()
		set (ORANGES_DOC_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/doc")
	endif()

	if(TARGET DependencyGraph)
		list (APPEND ORANGES_ARG_IMAGE_PATHS "${ORANGES_DOC_OUTPUT_DIR}/deps_graph.png")
		list (APPEND ORANGES_ARG_FILE_PATTERNS *.png)
	endif()

	list (REMOVE_DUPLICATES ORANGES_ARG_IMAGE_PATHS)
	list (REMOVE_DUPLICATES ORANGES_ARG_FILE_PATTERNS)

	list (JOIN ORANGES_ARG_IMAGE_PATHS " " ORANGES_DOXYGEN_INPUT_IMAGE_PATHS)
	list (JOIN ORANGES_ARG_FILE_PATTERNS " " ORANGES_DOXYGEN_INPUT_FILE_PATTERNS)

	set (doxyfile_output "${CMAKE_BINARY_DIR}/Doxyfile")
	set (doxylayout_output "${CMAKE_BINARY_DIR}/DoxygenLayout.xml")

	configure_file ("${ORANGES_DOXYFILE_INPUT}" "${doxyfile_output}" @ONLY)

	configure_file ("${ORANGES_DOXYLAYOUT_INPUT}" "${doxylayout_output}" @ONLY)

	if(NOT ORANGES_ARG_TARGET)
		set (ORANGES_ARG_TARGET "${PROJECT_NAME}Doxygen")
	endif()

	add_custom_target (
		"${ORANGES_ARG_TARGET}"
		COMMAND "${CMAKE_COMMAND}" -E make_directory "${ORANGES_DOC_OUTPUT_DIR}"
		COMMAND Doxygen::doxygen "${doxyfile_output}"
		WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
		VERBATIM
		DEPENDS "${ORANGES_DOXYFILE_INPUT}" "${doxyfile_output}" "${ORANGES_DOXYLAYOUT_INPUT}"
				"${doxylayout_output}"
		BYPRODUCTS "${ORANGES_DOC_OUTPUT_DIR}/html/index.html"
		COMMENT "Building ${PROJECT_NAME} documentation...")

	if(NOT ORANGES_ARG_NO_VERSION_DISPLAY)
		add_custom_command (
			TARGET "${ORANGES_ARG_TARGET}" PRE_BUILD COMMAND Doxygen::doxygen --version
			COMMENT "Doxygen version:")
	endif()

	if(TARGET DependencyGraph)
		add_dependencies ("${ORANGES_ARG_TARGET}" DependencyGraph)
	endif()

	set_target_properties ("${ORANGES_ARG_TARGET}" PROPERTIES ADDITIONAL_CLEAN_FILES
															  "${ORANGES_DOC_OUTPUT_DIR}")

	install (
		DIRECTORY "${ORANGES_DOC_OUTPUT_DIR}/man3"
		TYPE MAN
		COMPONENT "${PROJECT_NAME}_Documentation"
		EXCLUDE_FROM_ALL OPTIONAL
		PATTERN .DS_Store EXCLUDE)

	install (
		DIRECTORY "${ORANGES_DOC_OUTPUT_DIR}/html"
		TYPE INFO
		COMPONENT "${PROJECT_NAME}_Documentation"
		EXCLUDE_FROM_ALL OPTIONAL
		PATTERN .DS_Store EXCLUDE)

	install (FILES "${ORANGES_DOC_OUTPUT_DIR}/${PROJECT_NAME}.tag" TYPE INFO OPTIONAL
			 COMPONENT "${PROJECT_NAME}_Documentation")

	set ("CPACK_COMPONENT_${PROJECT_NAME}_Documentation_DISPLAY_NAME"
		 "${PROJECT_NAME} documentation")

	set ("CPACK_COMPONENT_${PROJECT_NAME}_Documentation_DESCRIPTION"
		 "Installs HTML and man-page documentation for ${PROJECT_NAME}")

	set ("CPACK_COMPONENT_${PROJECT_NAME}_Documentation_GROUP" Documentation)

	set (CPACK_COMPONENT_GROUP_Documentation_DESCRIPTION
		 "Installs all available sets of documentation")

endfunction()
