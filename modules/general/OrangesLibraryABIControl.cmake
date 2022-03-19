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

This module is a thin wrapper around CMake's generate_export_header.

Inclusion style: once globally

## Functions:

### oranges_add_library_abi_control
```
oranges_add_library_abi_control (TARGET <targetName>
								 [BASE_NAME <baseName>]
								 [HEADER <exportHeaderName>])
```

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

add_library (OrangesABIControlledLibrary INTERFACE)

set_target_properties (OrangesABIControlledLibrary PROPERTIES CXX_VISIBILITY_PRESET hidden
															  VISIBILITY_INLINES_HIDDEN TRUE)

oranges_export_alias_target (OrangesABIControlledLibrary Oranges)

option (ORANGES_REMOVE_DEPRECATED_CODE "Removes deprecated code from preprocessed output" OFF)

mark_as_advanced (FORCE ORANGES_REMOVE_DEPRECATED_CODE)

include (GenerateExportHeader)

#

function(oranges_add_library_abi_control)

	set (oneValueArgs TARGET BASE_NAME HEADER)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT ORANGES_ARG_HEADER)
		set (ORANGES_ARG_HEADER "${ORANGES_ARG_TARGET}_export.h")
	endif()

	if(NOT ORANGES_ARG_BASE_NAME)
		set (ORANGES_ARG_BASE_NAME "${ORANGES_ARG_TARGET}")
	endif()

	string (TOUPPER "${ORANGES_ARG_BASE_NAME}" upperBaseName)

	target_link_libraries ("${ORANGES_ARG_TARGET}" PRIVATE Oranges::OrangesABIControlledLibrary)

	set_target_properties (
		"${ORANGES_ARG_TARGET}" PROPERTIES COMPILE_FLAGS
										   -D${upperBaseName}SHARED_AND_STATIC_STATIC_DEFINE)

	if(ORANGES_REMOVE_DEPRECATED_CODE)
		set (no_build_deprecated DEFINE_NO_DEPRECATED)
	endif()

	generate_export_header ("${ORANGES_ARG_TARGET}" BASE_NAME "${ORANGES_ARG_BASE_NAME}"
							EXPORT_FILE_NAME "${ORANGES_ARG_HEADER}" ${no_build_deprecated})

endfunction()
