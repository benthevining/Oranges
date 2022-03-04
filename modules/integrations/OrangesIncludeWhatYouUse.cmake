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

include_guard (GLOBAL)

include (OrangesAllIntegrations)

find_program (lemons_iwyu_path NAMES include-what-you-use iwyu)

if(NOT lemons_iwyu_path)
	return ()
endif()

message (VERBOSE "Using include-what-you-use!")

set (CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${lemons_iwyu_path}")

add_library (OrangesIncludeWhatYouUse INTERFACE)

set_target_properties (OrangesIncludeWhatYouUse PROPERTIES CXX_INCLUDE_WHAT_YOU_USE
														   "${lemons_iwyu_path}")

target_link_libraries (OrangesAllIntegrations INTERFACE OrangesIncludeWhatYouUse)

add_library (Oranges::OrangesIncludeWhatYouUse ALIAS OrangesIncludeWhatYouUse)

install (TARGETS OrangesIncludeWhatYouUse EXPORT OrangesTargets OPTIONAL)
