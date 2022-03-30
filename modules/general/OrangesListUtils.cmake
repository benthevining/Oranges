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

OrangesListUtils
-------------------------

List processing utilities.
This module provides the function :command:`oranges_list_transform()`.

Call a function to transform each element in a list
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: oranges_list_transform

	oranges_list_transform (LIST <listVar>
							CALLBACK <functionName>
							[OUTPUT <outputVar>])

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (OrangesCmakeDevTools)

#

function(oranges_list_transform)

	oranges_add_function_message_context ()

	set (oneValueArgs LIST CALLBACK OUTPUT)

	cmake_parse_arguments (ORANGES_ARG "REMOVE_DUPLICATES" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG LIST CALLBACK)

	set (newList "")

	foreach(item ${ORANGES_ARG_LIST})
		cmake_language (CALL "${ORANGES_ARG_CALLBACK}" "${item}" new_item)

		if(new_item)
			list (APPEND newList "${new_item}")
		endif()
	endforeach()

	if(ORANGES_ARG_REMOVE_DUPLICATES)
		list (REMOVE_DUPLICATES newList)
	endif()

	unset (${ORANGES_ARG_LIST} PARENT_SCOPE)

	if(ORANGES_ARG_OUTPUT)
		unset (${ORANGES_ARG_OUTPUT} PARENT_SCOPE)
	endif()

	if(newList)
		if(ORANGES_ARG_OUTPUT)
			set (${ORANGES_ARG_OUTPUT} ${newList} PARENT_SCOPE)
		else()
			set (${ORANGES_ARG_LIST} ${newList} PARENT_SCOPE)
		endif()
	endif()
endfunction()