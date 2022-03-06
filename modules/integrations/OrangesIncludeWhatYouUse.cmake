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
include (LemonsCmakeDevTools)

find_program (lemons_iwyu_path NAMES include-what-you-use iwyu)

mark_as_advanced (FORCE lemons_iwyu_path)

if(NOT lemons_iwyu_path)
	return ()
endif()

message (VERBOSE "Using include-what-you-use!")

set (CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${lemons_iwyu_path}")

add_library (OrangesIncludeWhatYouUse INTERFACE)

set_target_properties (OrangesIncludeWhatYouUse PROPERTIES CXX_INCLUDE_WHAT_YOU_USE
														   "${lemons_iwyu_path}")

add_library (Oranges::OrangesIncludeWhatYouUse ALIAS OrangesIncludeWhatYouUse)

target_link_libraries (OrangesAllIntegrations INTERFACE Oranges::OrangesIncludeWhatYouUse)

oranges_install_targets (TARGETS OrangesIncludeWhatYouUse EXPORT OrangesTargets OPTIONAL)
