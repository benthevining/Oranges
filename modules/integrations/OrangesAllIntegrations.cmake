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

add_library (OrangesAllIntegrations INTERFACE)

include (OrangesCcache)
include (OrangesClangTidy)
include (OrangesCppCheck)
include (OrangesCppLint)
include (OrangesIncludeWhatYouUse)

add_library (Oranges::OrangesAllIntegrations ALIAS OrangesAllIntegrations)

install (TARGETS OrangesAllIntegrations EXPORT OrangesTargets OPTIONAL)