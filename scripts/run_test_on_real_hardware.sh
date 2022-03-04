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

readonly tester="$1"

shift

# create temporary file
filename="$(ssh root@172.22.22.22 mktemp)"
readonly filename

# copy the test executable to the temp file
scp "$tester" "root@172.22.22.22:$filename"

# make test executable
ssh root@172.22.22.22 chmod +x '$filename'

# execute test
ssh root@172.22.22.22 '$filename' '$@'

# store result
readonly success=$?

# clean up
ssh root@172.22.22.22 rm '$filename'

exit $success
