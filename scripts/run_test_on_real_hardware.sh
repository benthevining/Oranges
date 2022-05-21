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

# inputs:
# CROSSCOMPILING_TARGET_IP

readonly tester="$1"

shift

ssh_ip="${CROSSCOMPILING_TARGET_IP:-root@172.22.22.22}"
readonly ssh_ip

# create temporary file to hold the executable
test_exec="$(ssh '$ssh_ip' mktemp)"
readonly test_exec

# copy the test executable to the temp file
scp "$tester" "$ssh_ip:$test_exec"

# make the test executable
# shellcheck disable=SC2029
ssh "$ssh_ip" chmod +x "$test_exec"

# execute the test
ssh "$ssh_ip" "$test_exec" '$@'

# store result
readonly success=$?

# clean up
ssh "$ssh_ip" rm -rf "$test_exec"

exit $success
