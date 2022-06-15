#!/usr/bin/sh
# This script updates Oranges's .cmake-format.json file with all the command specifications in the OrangesCMakeCommands.json file.

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

script_dir="$(cd "$(dirname "$0")" && pwd)"

readonly script_dir

python3 "$script_dir/update_cmakeformat_config.py" \
	--input "$script_dir/../util/OrangesCMakeCommands.json" \
	--output "$script_dir/../.cmake-format.json"
