# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsCmakeDevTools)

lemons_warn_if_not_processing_project ()

# currently broken on windows...
if(WIN32)
	return ()
endif()

if(NOT (APPLE OR WIN32))
	return ()
endif()

if(IOS OR ANDROID)
	return ()
endif()

if(NOT LEMONS_AAX_SDK_PATH)
	return ()
endif()

if(NOT IS_DIRECTORY "${LEMONS_AAX_SDK_PATH}")
	message (WARNING "LEMONS_AAX_SDK_PATH has been specified, but the directory does not exist!")
	return ()
endif()

# Mac (xcodebuild)

if(APPLE)

	if(NOT "x86_64" IN_LIST CMAKE_OSX_ARCHITECTURES)
		message (
			WARNING
				"You're not building for x86_64, which will cause linker errors with AAX targets! Enable universal binaries to build for AAX."
			)
		return ()
	endif()

	find_program (XCODE_BUILD xcodebuild)

	if(NOT XCODE_BUILD)
		message (WARNING "xcodebuild is required to build the AAXSDK, but could not be found!")
		return ()
	endif()

	set (macBuildDir "${LEMONS_AAX_SDK_PATH}/Libs/AAXLibrary/MacBuild")

	set (xcode_proj_file "${macBuildDir}/AAXLibrary.xcodeproj")
	if(NOT EXISTS "${xcode_proj_file}")
		message (AUTHOR_WARNING "${xcode_proj_file} could not be found, AAX SDK cannot be built!")
		return ()
	endif()

	add_custom_target (
		AAXSDK
		COMMAND ${XCODE_BUILD} -scheme AAXLibrary_libcpp ONLY_ACTIVE_ARCH=NO ARCHS=x86_64
				-configuration "$<COMMAND_CONFIG:$<CONFIG>>" build
		COMMAND_EXPAND_LISTS VERBATIM
		WORKING_DIRECTORY "${macBuildDir}"
		COMMENT "Building AAX SDK..."
		COMMAND_ECHO STDOUT)

	set_target_properties (AAXSDK PROPERTIES OSX_ARCHITECTURES x86_64)

	# Windows (MSVC)

elseif(WIN32)

	set (msvc_proj_file "${LEMONS_AAX_SDK_PATH}/msvc/AAX_SDK.sln")

	if(NOT EXISTS "${msvc_proj_file}")
		message (AUTHOR_WARNING "${msvc_proj_file} could not be found, AAX SDK cannot be built!")
		return ()
	endif()

	include_external_msproject (AAXSDK "${msvc_proj_file}")

endif()

if(TARGET AAXSDK)
	message (DEBUG "Configured AAXSDK target!")
else()
	message (WARNING "Error configuring the AAXSDK target!")
endif()
