#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script generates a set of .rst files, one for each CMake module, that simply references the actual .cmake file in the source tree.

This script also generates an index.rst file, with a toc-tree linking to each module.
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

#

MODULES_ROOT: Final[str] = "@ORANGES_MODULES_ROOT@"

RST_OUTPUT_DIR: Final[str] = "@RST_OUTPUT_DIR@"

INPUT_INDEX_FILE: Final[str] = "@INPUT_INDEX_FILE@"

if not os.path.isdir(RST_OUTPUT_DIR):
	os.makedirs(RST_OUTPUT_DIR)

generated_files: list[str] = []

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

		output_file: Final[str] = os.path.join(
		    RST_OUTPUT_DIR, f"{entry.removesuffix('.cmake')}.rst")

		output_path: Final[str] = os.path.relpath(entry_path,
		                                          start=RST_OUTPUT_DIR)

		with open(output_file, "w", encoding="utf-8") as rst_out:
			rst_out.write(f".. cmake-module:: {output_path}")

		generated_files.append(output_file)


#

for dirname in os.listdir(MODULES_ROOT):
	if dirname == "internal":
		continue

	DIRPATH: Final[str] = os.path.join(MODULES_ROOT, dirname)

	if not os.path.isdir(DIRPATH):
		continue

	process_directory(DIRPATH)

#

with open(INPUT_INDEX_FILE, "r", encoding="utf-8") as index_in:
	index_lines = index_in.readlines()

OUTPUT_TREE_ROOT: Final[str] = os.path.abspath(os.path.dirname(RST_OUTPUT_DIR))

module_files: list[str] = []
find_modules: list[str] = []

for filepath in generated_files:
	REL_PATH: Final[str] = os.path.relpath(filepath, start=OUTPUT_TREE_ROOT)

	if os.path.basename(filepath).startswith("Find"):
		find_modules.append(REL_PATH)
	else:
		module_files.append(REL_PATH)

del generated_files

module_files.sort()
find_modules.sort()

index_lines.append("\nModules\n")
index_lines.append("##################\n")
index_lines.append("\n")
index_lines.append(".. toctree::\n")
index_lines.append("   :maxdepth: 1\n")
index_lines.append("   :caption: CMake modules provided by Oranges:\n")

for module in module_files:
	index_lines.append(f"\n   {module}")

del module_files

index_lines.append("\n")
index_lines.append("\nFind Modules\n")
index_lines.append("##################\n")
index_lines.append("\n")
index_lines.append(".. toctree::\n")
index_lines.append("   :maxdepth: 1\n")
index_lines.append("   :caption: Find modules provided by Oranges:\n")

for module in find_modules:
	index_lines.append(f"\n   {module}")

del find_modules

OUTPUT_INDEX: Final[str] = os.path.join(OUTPUT_TREE_ROOT, "index.rst")

with open(OUTPUT_INDEX, "w", encoding="utf-8") as index_out:
	index_out.write("".join(index_lines))
