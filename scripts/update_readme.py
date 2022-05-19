#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Simple script that inserts the list of CMake modules into the appropriate section of the readme.

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
import os


ORANGES_ROOT: Final[str] = "@Oranges_SOURCE_DIR@"

MODULES_ROOT: Final[str] = os.path.join(ORANGES_ROOT, "modules")

README: Final[str] = os.path.join(ORANGES_ROOT, "README.md")

#

module_lines: list[str] = []
find_module_lines: list[str] = []

#


def process_directory(dir_path: str) -> None:
	"""
	Processes all CMake modules in a directory, recursively.
	"""

	for entry in os.listdir(dir_path):

		if entry == "scripts":
			continue

		entry_path: Final[str] = os.path.join(dir_path, entry)

		if os.path.isdir(entry_path):
			process_directory(entry_path)
			continue

		if not os.path.isfile(entry_path):
			continue

		if not entry.endswith(".cmake"):
			continue

		filename: Final[str] = entry.removesuffix(".cmake")

		out_line: Final[
		    str] = f"  * [{filename}]({os.path.relpath(entry_path, start=ORANGES_ROOT)})\n"

		if filename.startswith("Find"):
			find_module_lines.append(out_line)
		else:
			module_lines.append(out_line)


#

for dirname in os.listdir(MODULES_ROOT):
	if dirname == "internal":
		continue

	DIRPATH: Final[str] = os.path.join(MODULES_ROOT, dirname)

	if not os.path.isdir(DIRPATH):
		continue

	process_directory(DIRPATH)

find_module_lines.sort()
module_lines.sort()

#

with open(README, "r", encoding="utf-8") as f:
	README_LINES: Final[list[str]] = f.readlines()

START_LINE: Final[str] = "## What's here\n"
END_LINE: Final[str] = "## Using Oranges\n"

output_lines: list[str] = README_LINES[0:README_LINES.index(START_LINE) + 1]
AFTER_LINES: Final[list[str]] = README_LINES[README_LINES.index(END_LINE):]

output_lines.append("\n")
output_lines.append("### Oranges provides the following CMake modules:\n")
output_lines.append("\n")

for module_line in module_lines:
	output_lines.append(module_line)

del module_lines

output_lines.append("\n")
output_lines.append("### Oranges provides the following find modules:\n")
output_lines.append("\n")

for find_mod_line in find_module_lines:
	output_lines.append(find_mod_line)

del find_module_lines

output_lines.append("\n")
output_lines.extend(AFTER_LINES)

with open(README, "w", encoding="utf-8") as f:
	f.write("".join(output_lines))
