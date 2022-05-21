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
from shutil import copytree
import os

#

ORANGES_ROOT: Final[str] = "@Oranges_SOURCE_DIR@"

MODULES_ROOT: Final[str] = os.path.join(ORANGES_ROOT, "modules")

OUTPUT_TREE_ROOT: Final[str] = "@ORANGES_DOCS_BUILD_TREE@"

MODULES_RST_OUTPUT_DIR: Final[str] = os.path.join(OUTPUT_TREE_ROOT, "modules")

# editorconfig-checker-disable
FIND_MODULES_RST_OUTPUT_DIR: Final[str] = os.path.join(OUTPUT_TREE_ROOT,
                                                       "find_modules")
# editorconfig-checker-enable

DOCS_DIR: Final[str] = "@CMAKE_CURRENT_LIST_DIR@"

if not os.path.isdir(MODULES_RST_OUTPUT_DIR):
	os.makedirs(MODULES_RST_OUTPUT_DIR)

if not os.path.isdir(FIND_MODULES_RST_OUTPUT_DIR):
	os.makedirs(FIND_MODULES_RST_OUTPUT_DIR)

#

# the .rst files for the scripts are static, so just copy them into the output tree

# editorconfig-checker-disable
copytree(src=os.path.join(DOCS_DIR, "scripts"),
         dst=os.path.join(OUTPUT_TREE_ROOT, "scripts"),
         dirs_exist_ok=True)
# editorconfig-checker-enable

#

# generate .rst files for each module


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

		if os.path.basename(entry_path).startswith("Find"):
			base_dir: Final[str] = FIND_MODULES_RST_OUTPUT_DIR
		else:
			base_dir: Final[str] = MODULES_RST_OUTPUT_DIR

		output_file: Final[str] = os.path.join(
		    base_dir, f"{entry.removesuffix('.cmake')}.rst")

		output_path: Final[str] = os.path.relpath(entry_path, start=base_dir)

		with open(output_file, "w", encoding="utf-8") as rst_out:
			rst_out.write(f".. cmake-module:: {output_path}")


#

for dirname in os.listdir(MODULES_ROOT):
	if dirname == "internal":
		continue

	DIRPATH: Final[str] = os.path.join(MODULES_ROOT, dirname)

	if not os.path.isdir(DIRPATH):
		continue

	process_directory(DIRPATH)

#

# generate a documentation page for the FindOranges script

# editorconfig-checker-disable
FIND_ORANGES_PATH: Final[str] = os.path.relpath(
    os.path.join(ORANGES_ROOT, "scripts/FindOranges.cmake"),
    start=os.path.join(OUTPUT_TREE_ROOT, "modules"))

FINDER_DOC_FILE: Final[str] = os.path.join(MODULES_RST_OUTPUT_DIR,
                                           "FindOranges.rst")
# editorconfig-checker-enable

with open(FINDER_DOC_FILE, "w", encoding="utf-8") as find_out:
	find_out.write(f".. cmake-module:: {FIND_ORANGES_PATH}")

#

# Read content from the index.rst file in the /docs dir
# editorconfig-checker-disable
with open(os.path.join(DOCS_DIR, "index.rst"), "r",
          encoding="utf-8") as index_in:
	index_lines = index_in.readlines()
# editorconfig-checker-enable

#

# Read content from the readme

# editorconfig-checker-disable
with open(os.path.join(ORANGES_ROOT, "README.md"), "r",
          encoding="utf-8") as readme_in:
	readme_lines = readme_in.readlines()
# editorconfig-checker-enable

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
		    f"\n:doc:`View the documentation for the FindOranges script. <{os.path.splitext(os.path.relpath(FINDER_DOC_FILE, start=OUTPUT_TREE_ROOT))[0]}>`\n"
		)
		continue

	if line.startswith("#"):
		index_lines.append(f"\n{line.replace('#', '').strip()}\n")
		index_lines.append("##################\n")
	else:
		index_lines.append(f"{line}")

del readme_lines
del FINDER_DOC_FILE

#

# Build the actual index.rst for the docs build tree

index_lines.append("\nModules\n")
index_lines.append("##################\n")
index_lines.append("\n")
index_lines.append(".. toctree::\n")
index_lines.append("   :maxdepth: 1\n")
index_lines.append("   :caption: CMake modules provided by Oranges:\n")
index_lines.append("   :glob:\n\n")
index_lines.append("   modules/*")

index_lines.append("\n")
index_lines.append("\nFind Modules\n")
index_lines.append("##################\n")
index_lines.append("\n")
index_lines.append(".. toctree::\n")
index_lines.append("   :maxdepth: 1\n")
index_lines.append("   :caption: Find modules provided by Oranges:\n")
index_lines.append("   :glob:\n\n")
index_lines.append("   find_modules/*")

index_lines.append("\n\n")

# append content from scripts.rst file in this directory
# editorconfig-checker-disable
with open(os.path.join(DOCS_DIR, "scripts.rst"), "r",
          encoding="utf-8") as scripts_in:
	index_lines.extend(scripts_in.readlines())
# editorconfig-checker-enable

OUTPUT_INDEX: Final[str] = os.path.join(OUTPUT_TREE_ROOT, "index.rst")

with open(OUTPUT_INDEX, "w", encoding="utf-8") as index_out:
	index_out.write("".join(index_lines))
