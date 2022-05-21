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

ORANGES_ROOT: Final[str] = "@Oranges_SOURCE_DIR@"

MODULES_ROOT: Final[str] = os.path.join(ORANGES_ROOT, "modules")

ORANGES_README: Final[str] = os.path.join(ORANGES_ROOT, "README.md")

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

OUTPUT_TREE_ROOT: Final[str] = os.path.abspath(os.path.dirname(RST_OUTPUT_DIR))

# generate a documentation page for the FindOranges script

# editorconfig-checker-disable
FIND_ORANGES_PATH: Final[str] = os.path.relpath(
    os.path.join(ORANGES_ROOT, "scripts/FindOranges.cmake"),
    start=os.path.join(OUTPUT_TREE_ROOT, "modules"))
# editorconfig-checker-enable

FINDER_DOC_FILE: Final[str] = os.path.join(RST_OUTPUT_DIR, "FindOranges.rst")

with open(FINDER_DOC_FILE, "w", encoding="utf-8") as find_out:
	find_out.write(f".. cmake-module:: {FIND_ORANGES_PATH}")

#

with open(INPUT_INDEX_FILE, "r", encoding="utf-8") as index_in:
	index_lines = index_in.readlines()

module_files: list[str] = []
find_modules: list[str] = []

for filepath in generated_files:
	REL_PATH: Final[str] = os.path.relpath(filepath, start=OUTPUT_TREE_ROOT)

	if os.path.basename(filepath).startswith("Find"):
		find_modules.append(REL_PATH)
	else:
		module_files.append(REL_PATH)

del generated_files

#

with open(ORANGES_README, "r", encoding="utf-8") as readme_in:
	readme_lines = readme_in.readlines()

README_START_LINE: Final[str] = "## Using Oranges\n"
README_END_LINE: Final[str] = "## Dependency graph\n"

# editorconfig-checker-disable
readme_lines = readme_lines[readme_lines.index(README_START_LINE):readme_lines
                            .index(README_END_LINE) - 1]
# editorconfig-checker-enable

for line in readme_lines:
	if line.startswith(
	    "See the [``FindOranges``](scripts/FindOranges.cmake) file for more documentation on what it does."
	):
		index_lines.append(
		    "\n:doc:`View the documentation for the FindOranges script. <modules/FindOranges>`\n"
		)
		continue

	if line.startswith("#"):
		index_lines.append(f"\n{line.replace('#', '').strip()}\n")
		index_lines.append("##################\n")
	else:
		index_lines.append(f"{line}")

del readme_lines

#

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
