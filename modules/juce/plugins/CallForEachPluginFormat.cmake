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

CallForEachPluginFormat
-------------------------

This module provides the function :command:`call_for_each_plugin_format()`.

Calling a function for each plugin format
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: call_for_each_plugin_format

	call_for_each_plugin_format (TARGET <pluginTarget>
								 FUNCTION <functionName>)

This function calls a given command for each plugin format of the given plugin base target.

The passed `FUNCTION` must have the signature:
```
your_callback (targetName formatName)
```
where `targetName` is the name of the plugin format's specific target, that has already been checked for existence, and `formatName` is the name of the plugin format (eg, 'AAX' or 'VST3').


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (LemonsCmakeDevTools)

function(call_for_each_plugin_format)

	oranges_add_function_message_context ()

	set (oneValueArgs TARGET FUNCTION)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET FUNCTION)
	oranges_assert_target_argument_is_target (ORANGES_ARG)

	if(NOT COMMAND "${ORANGES_ARG_FUNCTION}")
		message (
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION} called with non-existent command name ${ORANGES_ARG_FUNCTION}!"
			)
	endif()

	get_required_target_property (plugin_formats "${ORANGES_ARG_TARGET}" JUCE_FORMATS)

	foreach(format IN LISTS plugin_formats)

		set (targetName "${ORANGES_ARG_TARGET}_${format}")

		if(NOT TARGET "${targetName}")
			message (WARNING "Plugin format target ${targetName} does not exist!")
			continue ()
		endif()

		cmake_language (CALL "${ORANGES_ARG_FUNCTION}" "${targetName}" "${format}")

	endforeach()

endfunction()
