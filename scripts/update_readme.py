#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Simple script that inserts the list of CMake modules (output by the help script) into the appropriate section of the readme.

This script is meant to be configured and invoked by CMake.
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

from typing import Final


MODULE_LIST: Final[str] = "@modules_output@"
README: Final[str] = "@readme@"

MODULES_SECTION_START: Final[str] = "## What's here"
MODULES_SECTION_END: Final[str] = "## Using Oranges"

if __name__ == "__main__":
	with open(README, "r", encoding="utf-8") as f:
		README_LINES: Final[list[str]] = f.readlines()

	stripped_lines: list[str] = []

	inModulesSection: bool = False

	for line in README_LINES:
		if line.startswith(MODULES_SECTION_START):
			inModulesSection = True  # pylint: disable=invalid-name
			stripped_lines.append(line)
			continue

		if line.startswith(MODULES_SECTION_END):
			inModulesSection = False  # pylint: disable=invalid-name
			stripped_lines.append(line)
			continue

		if not inModulesSection:
			stripped_lines.append(line)

	del README_LINES
	del inModulesSection

	with open(MODULE_LIST, "r", encoding="utf-8") as f:
		module_lines: list[str] = f.readlines()

	for idx, line in enumerate(module_lines):
		if line.startswith("Oranges provides"):
			module_lines[idx] = f"### {line}"

	output_lines: list[str] = []

	for line in stripped_lines:
		output_lines.append(line)

		if line.startswith(MODULES_SECTION_START):
			output_lines.append("\n")
			output_lines.extend(module_lines)
			output_lines.append("\n")

	with open(README, "w", encoding="utf-8") as f:
		f.write("".join(output_lines))
