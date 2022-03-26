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

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ORANGES_ROOT="$SCRIPT_DIR/../.."

OUTPUT_FILE="$ORANGES_ROOT/Makefile"

if [ -f "$OUTPUT_FILE" ]; then
	rm -rf "$OUTPUT_FILE"
fi

cmake -D PROJECT_NAME=ORANGES -D "OUT_FILE=$OUTPUT_FILE" -P "$SCRIPT_DIR/generate_makefile.cmake"
