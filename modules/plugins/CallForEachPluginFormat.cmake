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

This module provides the function call_for_each_plugin_format.

Inclusion style: once globally

## Function:

### call_for_each_plugin_format
```
call_for_each_plugin_format (TARGET <pluginTarget>
							 FUNCTION <functionName>)
```

This function calls a given command for each plugin format of the given plugin base target.

The passed `FUNCTION` must have the signature:
```
your_callback (targetName formatName)
```
where `targetName` is the name of the plugin format's specific target, that has already been checked for existence, and `formatName` is the name of the plugin format (eg, 'AAX' or 'VST3').

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

function(call_for_each_plugin_format)

	set (oneValueArgs TARGET FUNCTION)

	cmake_parse_arguments (ORANGES_ARG "" "" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET FUNCTION)

	if(NOT TARGET "${ORANGES_ARG_TARGET}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent target ${ORANGES_ARG_TARGET}!")
	endif()

	if(NOT COMMAND "${ORANGES_ARG_FUNCTION}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent command name ${ORANGES_ARG_FUNCTION}!"
			)
	endif()

	get_target_property (plugin_formats "${ORANGES_ARG_TARGET}" JUCE_FORMATS)

	if(NOT plugin_formats)
		message (FATAL_ERROR "Error retrieving plugin formats from target ${ORANGES_ARG_TARGET}!")
	endif()

	foreach(format ${plugin_formats})

		set (targetName "${ORANGES_ARG_TARGET}_${format}")

		if(NOT TARGET "${targetName}")
			message (WARNING "Plugin format target ${targetName} does not exist!")
			continue ()
		endif()

		cmake_language (CALL "${ORANGES_ARG_FUNCTION}" "${targetName}" "${format}")

	endforeach()

endfunction()
