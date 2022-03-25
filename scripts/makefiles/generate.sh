#!/bin/sh

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

BASEDIR=$(dirname "$0")

CMAKE_SCRIPT="$BASEDIR/generate_makefile.cmake"
OUTPUT_FILE="$BASEDIR/../../Makefile"

if ! [ -f "$CMAKE_SCRIPT" ]; then
	curl -o "$CMAKE_SCRIPT" "https://raw.githubusercontent.com/benthevining/Oranges/main/scripts/makefiles/generate_makefile.cmake"
fi

if [ -f "$OUTPUT_FILE" ]; then
	rm -rf "$OUTPUT_FILE"
fi

cmake -D PROJECT_NAME=ORANGES -D "OUT_FILE=$OUTPUT_FILE" -P "$CMAKE_SCRIPT"
