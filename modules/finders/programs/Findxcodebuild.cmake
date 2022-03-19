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

Find module for xcodebuild.

Targets:
- Apple::xcodebuild : xcodebuild executable

Output variables:
- xcodebuild_FOUND

## Functions:

### include_external_xcode_project
```
include_external_xcode_project (TARGET <targetName>
								DIRECTORY <dirOfXcodeProject>
								SCHEME <nameOfScheme>
								[EXTRA_ARGS <extraXcodebuildArgs>]
								[COMMENT <buildComment>])
```

Adds an external Xcode project to the build, similar to the CMake-native include_external_msproject command.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	xcodebuild PROPERTIES
	URL "https://developer.apple.com/library/archive/technotes/tn2339/_index.html"
	DESCRIPTION "Command-line build tool for XCode")

set (xcodebuild_FOUND FALSE)

find_program (XCODE_BUILD xcodebuild)

mark_as_advanced (FORCE XCODE_BUILD)

if(XCODE_BUILD)
	add_executable (xcodebuild IMPORTED GLOBAL)

	set_target_properties (xcodebuild PROPERTIES IMPORTED_LOCATION "${XCODE_BUILD}")

	add_executable (Apple::xcodebuild ALIAS xcodebuild)

	set (xcodebuild_FOUND TRUE)
else()
	find_package_warning_or_error ("xcodebuild program cannot be found!")
endif()

#

function(include_external_xcode_project)

	set (oneValueArgs TARGET DIRECTORY SCHEME EXTRA_ARGS COMMENT)

	cmake_parse_arguments (ORANGES_ARG "" "" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG TARGET DIRECTORY SCHEME)
	lemons_check_for_unparsed_args (ORANGES_ARG)

	if(NOT TARGET Apple::xcodebuild)
		message (FATAL_ERROR "xcodebuild cannot be found, xcode project target cannot be created!")
		return ()
	endif()

	if(NOT ORANGES_ARG_COMMENT)
		set (ORANGES_ARG_COMMENT "Building ${ORANGES_ARG_TARGET}...")
	endif()

	add_custom_target (
		"${ORANGES_ARG_TARGET}"
		COMMAND Apple::xcodebuild -scheme "${ORANGES_ARG_SCHEME}" -configuration
				$<COMMAND_CONFIG:$<CONFIG>> ${ORANGES_ARG_EXTRA_ARGS} build
		COMMAND_EXPAND_LISTS VERBATIM USES_TERMINAL
		WORKING_DIRECTORY "${ORANGES_ARG_DIRECTORY}"
		COMMENT "${ORANGES_ARG_COMMENT}"
		COMMAND_ECHO STDOUT)

endfunction()
