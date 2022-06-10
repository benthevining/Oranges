#!/bin/sh

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

python3 "$script_dir/generate_find_module.py" \
	-p Oranges \
	-r https://github.com/benthevining/Oranges \
	-t origin/main \
	-d "CMake modules and scripts" \
	-o "$script_dir/../scripts/" \
	--post-commands "list (APPEND CMAKE_MODULE_PATH \${ORANGES_CMAKE_MODULE_PATH})"
