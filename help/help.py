#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Oranges help script.

This script is a simple command line interface providing quick reference for Oranges, similar to CMake's CLI help functionality. You can use this
script to list or view help for Oranges modules, commands, or targets. Any output from this script can also be dumped to a file.
"""

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

from oranges_help import main as oranges

if __name__ == "__main__":
	oranges.main()
