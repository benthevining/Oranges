#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This module contains some basic printing helper functions.
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


def section_heading(text: str) -> None:
	"""
	Prints the line of text to the terminal, with ANSI bold and underline color codes applied.
	"""

	print(f"\033[1;30m\033[04m {text}\033[0m")


def error(text: str) -> None:
	"""
	Prints the line of text to the terminal, with ANSI bold and red color codes applied.
	"""

	print(f"\033[1;31m {text}\033[0m")
