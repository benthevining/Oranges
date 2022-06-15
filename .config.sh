#!/bin/sh
# This file exports the ORANGES_PATH environment variable.
# This variable allows any CMake project consuming Oranges to find this directory locally, instead of fetching the sources from GitHub.
# I recommend that you source this script from your shell startup script.

# @formatter:off
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
# @formatter:on

# Public: The path to the Oranges repository root.
# This environment variable is checked by the FindOranges.cmake module shipped with Oranges,
# so if consuming CMake projects use this module to include Oranges, then if this script has
# been sourced, this local directory will be found by the CMake configuration.
export ORANGES_PATH="${ORANGES_PATH:-$(cd "$(dirname "$0")" && pwd)}"

# Public: This function changes the current working directory to the Oranges repository.
go_oranges() {
	cd "$ORANGES_PATH" || exit 1
}
