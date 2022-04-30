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

OrangesJUCEUtilities
-------------------------

General JUCE CMake utilities.
This module finds the JUCE package and provides the functions :command:`lemons_enable_plugin_hosting()` and :command:`lemons_configure_juce_target()`.


Enable plugin hosting for a JUCE target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: lemons_enable_plugin_hosting

    lemons_enable_plugin_hosting (target)


Configure a JUCE target
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: lemons_configure_juce_target

  ::

    lemons_configure_juce_target (TARGET <target>
                                 [ASSET_FOLDER <folder>]
                                 [PLUGIN_HOST] [BROWSER] [CAMERA] [MICROPHONE]
                                 [NO_MODULES])

Configures default settings for JUCE targets that are common to apps and plugins. ``TARGET`` is required and, for plugins, must be the name of the plugin's shared code target (usually your product name).
The specified target will be linked to ``LemonsCommonModules``, unless the ``NO_MODULES`` option is present.

If ``ASSET_FOLDER`` is specified, :command:`lemons_add_resources_folder()` will be called for you with the specified folder name.

The ``PLUGIN_HOST``, ``BROWSER``, ``CAMERA``, and ``MICROPHONE`` options are all optional, and enable additional functionality for this plugin's targets.


#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesDefaultProjectSettings)
include (OrangesDefaultTarget)
include (OrangesCmakeDevTools)

#

find_package (JUCE REQUIRED)

include (OrangesAssetsHelpers)

#

function (lemons_enable_plugin_hosting target)
	if (IOS)
		return ()
	endif ()

	target_compile_definitions ("${target}" PRIVATE JUCE_PLUGINHOST_VST3=1
													JUCE_PLUGINHOST_LADSPA=1)

	if (LEMONS_VST2_SDK_PATH)
		target_compile_definitions ("${target}" PRIVATE JUCE_PLUGINHOST_VST=1)
	endif ()

	if (APPLE)
		target_compile_definitions ("${target}" PRIVATE JUCE_PLUGINHOST_AU=1)
	endif ()
endfunction ()

#

function (lemons_configure_juce_target)

	oranges_add_function_message_context ()

	set (options BROWSER PLUGIN_HOST CAMERA MICROPHONE TRANSLATIONS NO_MODULES)
	set (oneValueArgs TARGET ASSET_FOLDER)

	cmake_parse_arguments (LEMONS_TARGETCONFIG "${options}" "${oneValueArgs}"
						   "" ${ARGN})

	lemons_require_function_arguments (LEMONS_TARGETCONFIG TARGET)
	lemons_check_for_unparsed_args (LEMONS_TARGETCONFIG)
	oranges_assert_target_argument_is_target (LEMONS_TARGETCONFIG)

	target_compile_definitions (
		${LEMONS_TARGETCONFIG_TARGET}
		PRIVATE
			JUCE_VST3_CAN_REPLACE_VST2=0
			JUCE_APPLICATION_NAME_STRING=$<TARGET_PROPERTY:${LEMONS_TARGETCONFIG_TARGET},JUCE_PRODUCT_NAME>
			JUCE_APPLICATION_VERSION_STRING=$<TARGET_PROPERTY:${LEMONS_TARGETCONFIG_TARGET},JUCE_VERSION>
			JUCE_COREGRAPHICS_DRAW_ASYNC=1
			JUCE_STRICT_REFCOUNTEDPTR=1
			JUCE_MODAL_LOOPS_PERMITTED=0
			JUCE_JACK=1
			JUCE_DISABLE_AUDIO_MIXING_WITH_OTHER_APPS=1
			JUCE_EXECUTE_APP_SUSPEND_ON_BACKGROUND_TASK=1
			JUCE_DISPLAY_SPLASH_SCREEN=0
			_CRT_SECURE_NO_WARNINGS=1)

	target_link_libraries (${LEMONS_TARGETCONFIG_TARGET}
						   PRIVATE Oranges::OrangesDefaultTarget)

	if (NOT LEMONS_TARGETCONFIG_NO_MODULES)
		if (TARGET Lemons::LemonsCommonModules)
			target_link_libraries (${LEMONS_TARGETCONFIG_TARGET}
								   PRIVATE Lemons::LemonsCommonModules)
		else ()
			message (
				DEBUG
				"No target Lemons::LemonsCommonModules in call to ${CMAKE_CURRENT_FUNCTION}..."
				)
		endif ()
	endif ()

	if (LEMONS_TARGETCONFIG_ASSET_FOLDER)
		lemons_add_resources_folder (${ARGN})
	else ()
		if (LEMONS_TARGETCONFIG_TRANSLATIONS)
			message (
				AUTHOR_WARNING
					"Translation file generation requested without enabling a binary resources target!"
				)
		endif ()
	endif ()

	if (LEMONS_TARGETCONFIG_BROWSER)
		target_compile_definitions (
			"${LEMONS_TARGETCONFIG_TARGET}"
			PRIVATE JUCE_WEB_BROWSER=1 JUCE_USE_CURL=1
					JUCE_LOAD_CURL_SYMBOLS_LAZILY=1)

		target_link_libraries (
			"${LEMONS_TARGETCONFIG_TARGET}"
			PRIVATE
				$<NOT:$<OR:$<$<PLATFORM_ID:Windows>>,$<$<PLATFORM_ID:Darwin>>>,juce::pkgconfig_JUCE_CURL_LINUX_DEPS>
			)
	else ()
		target_compile_definitions ("${LEMONS_TARGETCONFIG_TARGET}"
									PRIVATE JUCE_WEB_BROWSER=0 JUCE_USE_CURL=0)
	endif ()

	if (LEMONS_TARGETCONFIG_PLUGIN_HOST)
		lemons_enable_plugin_hosting ("${LEMONS_TARGETCONFIG_TARGET}")
	endif ()

	if (LEMONS_TARGETCONFIG_CAMERA)
		target_compile_definitions (${LEMONS_TARGETCONFIG_TARGET}
									PRIVATE JUCE_USE_CAMERA=1)
		target_link_libraries (${LEMONS_TARGETCONFIG_TARGET} PRIVATE juce_video)
	endif ()

	if (LEMONS_TARGETCONFIG_MICROPHONE)
		target_compile_definitions (
			${LEMONS_TARGETCONFIG_TARGET}
			PRIVATE JUCE_MICROPHONE_PERMISSION_ENABLED=1)
	endif ()
endfunction ()
