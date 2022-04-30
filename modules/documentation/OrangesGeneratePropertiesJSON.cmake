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

OrangesGeneratePropertiesJSON
------------------------------

This module provides the function :command:`oranges_generate_properties_json()`.

Generating a JSON file listing all properties defined by a CMake project
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_generate_properties_json

	oranges_generate_properties_json (INPUT_FILE <filePath>
									  OUTPUT_FILE <filePath>
									  [USE_TARGET <target>]
									  [KEEP_INPUT_FILE])

This function parses an input file containing a list of property names and scopes, and produces a JSON file containing each property as an object with name, scope, brief docs and full docs fields.

The input file should be a simple text file with one line per property, and each line beginning with the name of a property, followed by a space and the property's scope.

For example:
```
Property1 GLOBAL
Property2 TARGET
Property3 GLOBAL
```

The `<target>` option will be passed to `get_property()`, since you must specify a target name even for retrieving docstrings. (If none is specified, the default is OrangesDefaultTarget.)

If the `KEEP_INPUT_FILE` flag is not present, this function will delete the `INPUT_FILE` as its final operation. This is to prevent successive runs of CMake from re-populating the input file.

A typical way to integrate this functionality into a project is to write property info into the intermediate "property list file" as soon as they are defined, for example:

```
# in top-level CMakeLists.txt:

set (MYPROJ_PROPERTIES_LIST_FILE "${PROJECT_BINARY_DIR}" CACHE INTERNAL "")

add_subdirectory (MySubdir)


# in subdirectory MySubdir:

define_property (
	TARGET PROPERTY MyCoolProperty
	BRIEF_DOCS "..."
	FULL_DOCS "..."
	)

define_property (
	GLOBAL PROPERTY MyOtherCoolProperty
	BRIEF_DOCS "..."
	FULL_DOCS "..."
	)

if(MYPROJ_PROPERTIES_LIST_FILE)
	file (
		APPEND "${MYPROJ_PROPERTIES_LIST_FILE}"
		"MyCoolProperty TARGET\nMyOtherCoolProperty GLOBAL\n"
	)
endif()



# back in top-level CMakeLists.txt, after add_subdirectory (MySubdir):

include (OrangesGeneratePropertiesJSON)

oranges_generate_properties_json (
	INPUT_FILE "${MYPROJ_PROPERTIES_LIST_FILE}"
	OUTPUT_FILE "${PROJECT_BINARY_DIR}/properties.json")
```

You can alternatively hand-write a persistent input file for this function and use the `KEEP_INPUT_FILE` flag when calling it.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesFunctionArgumentHelpers)
include (OrangesDefaultTarget)

function (oranges_generate_properties_json)

	set (oneValueArgs INPUT_FILE OUTPUT_FILE USE_TARGET)

	cmake_parse_arguments (ORANGES_ARG "KEEP_INPUT_FILE" "${oneValueArgs}" ""
						   ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG INPUT_FILE OUTPUT_FILE)

	if (NOT EXISTS "${ORANGES_ARG_INPUT_FILE}")
		message (
			WARNING
				"Cannot generate properties docs, list file ${ORANGES_ARG_INPUT_FILE} does not exist!"
			)
		return ()
	endif ()

	if (NOT ORANGES_ARG_USE_TARGET)
		set (ORANGES_ARG_USE_TARGET OrangesDefaultTarget)
	endif ()

	file (STRINGS "${ORANGES_ARG_INPUT_FILE}" prop_lines)

	set (properties_json "{ \"properties\": [ ] }")

	set (property_idx 0)

	foreach (line IN LISTS prop_lines)

		string (STRIP "${line}" line)

		if (NOT line)
			continue ()
		endif ()

		string (FIND "${line}" " " space_pos)

		string (SUBSTRING "${line}" 0 "${space_pos}" property_name)
		string (SUBSTRING "${line}" "${space_pos}" -1 property_scope)

		string (STRIP "${property_name}" property_name)
		string (STRIP "${property_scope}" property_scope)

		if ("${property_scope}" MATCHES TARGET)
			set (scope TARGET "${ORANGES_ARG_USE_TARGET}")
		else ()
			set (scope "${property_scope}")
		endif ()

		get_property (prop_brief_docs ${scope} PROPERTY "${property_name}"
					  BRIEF_DOCS)

		get_property (prop_full_docs ${scope} PROPERTY "${property_name}"
					  FULL_DOCS)

		string (
			JSON
			properties_json
			SET
			"${properties_json}"
			properties
			"${property_idx}"
			"{ \"name\": \"${property_name}\", \"kind\": \"${property_scope}\", \"briefDocs\": \"${prop_brief_docs}\", \"fullDocs\": \"${prop_full_docs}\" }"
			)

		math (EXPR property_idx "${property_idx}+1" OUTPUT_FORMAT DECIMAL)

	endforeach ()

	file (WRITE "${ORANGES_ARG_OUTPUT_FILE}" "${properties_json}")

	if (NOT ORANGES_ARG_KEEP_INPUT_FILE)
		file (REMOVE "${ORANGES_ARG_INPUT_FILE}")
	endif ()

	set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
				  PROPERTY CMAKE_CONFIGURE_DEPENDS "${ORANGES_ARG_INPUT_FILE}")

	set_property (DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" APPEND
				  PROPERTY ADDITIONAL_CLEAN_FILES "${ORANGES_ARG_OUTPUT_FILE}")

endfunction ()
