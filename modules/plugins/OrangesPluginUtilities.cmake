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

OrangesPluginUtilities
-------------------------

Utilities for audio plugins.
This module provides the function :command:`lemons_configure_juce_plugin()`.


Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- LEMONS_INCLUDE_PRIVATE_SDKS
- LEMONS_VST2_SDK_PATH
- LEMONS_AAX_SDK_PATH
- environment variable: LEMONS_PRIVATE_SDKS


Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- LEMONS_PLUGIN_FORMATS


Configure a JUCE plugin target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: lemons_configure_juce_plugin

	lemons_configure_juce_plugin (TARGET <target>
								  [AAX_PAGETABLE_FILE <file>] [AAX_GUID <guid>])

Forwards `${ARGN}` to lemons_configure_juce_target.

If an AAX-format target exists for this plugin, then [lemons_configure_aax_plugin()](@ref lemons_configure_aax_plugin) will be called for you. The `AAX_PAGETABLE_FILE` and `AAX_GUID` options will be forwarded, if present.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesJuceUtilities)
include (OrangesCmakeDevTools)
include (lemons_AggregateTargets)

oranges_file_scoped_message_context ("LemonsPluginUtilities")

option (LEMONS_INCLUDE_PRIVATE_SDKS "Add the PrivateSDKs repo via CPM.cmake" OFF)

mark_as_advanced (FORCE LEMONS_INCLUDE_PRIVATE_SDKS)

if(LEMONS_INCLUDE_PRIVATE_SDKS OR FETCHCONTENT_SOURCE_DIR_PrivateSDKs OR DEFINED
																		 ENV{LEMONS_PRIVATE_SDKS})
	include (OrangesAddPrivateSDKs)
endif()

if(LEMONS_AAX_SDK_PATH)
	include (OrangesAAXUtils)
endif()

lemons_warn_if_not_processing_project ()

#

if(NOT LEMONS_PLUGIN_FORMATS)

	set (available_formats Standalone)

	if(APPLE AND XCODE)
		list (APPEND available_formats AUv3)
	endif()

	if(NOT IOS)
		list (APPEND available_formats Unity VST3)

		if(APPLE)
			list (APPEND available_formats AU)
		endif()

		if(TARGET AAXSDK)
			list (APPEND available_formats AAX)
		endif()

		if(LEMONS_VST2_SDK_PATH)
			if(IS_DIRECTORY "${LEMONS_VST2_SDK_PATH}")
				juce_set_vst2_sdk_path ("${LEMONS_VST2_SDK_PATH}")
				list (APPEND available_formats VST)
			else()
				message (
					AUTHOR_WARNING
						"LEMONS_VST2_SDK_PATH specified, but the directory does not exist!")
			endif()
		endif()
	endif()

	set (LEMONS_PLUGIN_FORMATS ${available_formats} CACHE STRING "Available plugin formats")

	unset (available_formats)

	mark_as_advanced (LEMONS_PLUGIN_FORMATS)

endif()

lemons_make_variable_const (LEMONS_PLUGIN_FORMATS)

list (JOIN LEMONS_PLUGIN_FORMATS " " formats_output)
message (STATUS "  -- Available plugin formats: ${formats_output}")

#

function(lemons_configure_juce_plugin)

	oranges_add_function_message_context ()

	lemons_configure_juce_target (${ARGN})

	set (oneValueArgs TARGET AAX_PAGETABLE_FILE AAX_GUID)
	cmake_parse_arguments (LEMONS_PLUGIN "" "${oneValueArgs}" "" ${ARGN})

	oranges_assert_target_argument_is_target (LEMONS_PLUGIN)

	set (aax_target "${LEMONS_PLUGIN_TARGET}_AAX")
	if(TARGET ${aax_target})
		message (DEBUG "Configuring AAX plugin target...")

		lemons_configure_aax_plugin (
			TARGET ${aax_target} PAGETABLE_FILE "${LEMONS_PLUGIN_AAX_PAGETABLE_FILE}" GUID
			"${LEMONS_PLUGIN_AAX_GUID}")
	endif()

	if(TARGET Lemons::LemonsPluginModules)
		target_link_libraries (${LEMONS_PLUGIN_TARGET} PRIVATE Lemons::LemonsPluginModules)
	else()
		message (DEBUG
				 "No target Lemons::LemonsPluginModules in call to ${CMAKE_CURRENT_FUNCTION}...")
	endif()

	target_compile_definitions (${LEMONS_PLUGIN_TARGET}
								PRIVATE JUCE_USE_CUSTOM_PLUGIN_STANDALONE_APP=0)

	_lemons_add_to_all_plugins_target (${LEMONS_PLUGIN_TARGET})

	# This dependency is needed to build Standalone and AUv3 targets, but isn't needed directly by
	# my lemons_plugin module, so add it to those targets here...
	function(_lemons_add_extra_pluginformat_modules formatTarget)
		if(TARGET ${formatTarget})
			target_link_libraries (${formatTarget} PRIVATE juce::juce_audio_devices)
		endif()
	endfunction()

	_lemons_add_extra_pluginformat_modules (${LEMONS_PLUGIN_TARGET}_Standalone)
	_lemons_add_extra_pluginformat_modules (${LEMONS_PLUGIN_TARGET}_AUv3)

endfunction()
