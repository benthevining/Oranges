#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script prepares a build tree for Sphinx by performing the following tasks:

* generating a .rst file for each module, command, variable, and property
* generating a UsingOranges.rst file populated with text from the Readme
* copying the .rst files in this directory (/docs) into the docs build tree
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
from shutil import copytree, copy2
import os
import sys


sys.path.insert(0, "@CMAKE_CURRENT_LIST_DIR@")

# pylint: disable=wrong-import-position
from process_source_tree import process_directory

#

ORANGES_ROOT: Final[str] = "@Oranges_SOURCE_DIR@"

MODULES_ROOT: Final[str] = os.path.join(ORANGES_ROOT, "modules")

OUTPUT_TREE_ROOT: Final[str] = "@ORANGES_DOCS_BUILD_TREE@"

DOCS_DIR: Final[str] = "@CMAKE_CURRENT_LIST_DIR@"

#

for subdir_name in "module", "find_modules", "command", "variable", "envvar", "prop_tgt", "prop_gbl":
	subdir_path = os.path.join(OUTPUT_TREE_ROOT, subdir_name)
	if not os.path.isdir(subdir_path):
		os.makedirs(subdir_path)

# the .rst files in this directory are static, so just copy them into the output tree

# editorconfig-checker-disable

copytree(src=os.path.join(DOCS_DIR, "scripts"),
         dst=os.path.join(OUTPUT_TREE_ROOT, "scripts"),
         dirs_exist_ok=True)

for filename in "modules", "scripts", "commands", "variables", "env_variables", "properties", "index":
	copy2(os.path.join(DOCS_DIR, f"{filename}.rst"),
	      os.path.join(OUTPUT_TREE_ROOT, f"{filename}.rst"))

# editorconfig-checker-enable

#

# generate .rst files for each module & command

for dirname in os.listdir(MODULES_ROOT):
	if dirname == "internal":
		continue

	DIRPATH: Final[str] = os.path.join(MODULES_ROOT, dirname)

	if not os.path.isdir(DIRPATH):
		continue

	process_directory(dir_path=DIRPATH, output_base_dir=OUTPUT_TREE_ROOT)

#

# generate a documentation page for the FindOranges script

# editorconfig-checker-disable
FIND_ORANGES_PATH: Final[str] = os.path.relpath(os.path.join(
    ORANGES_ROOT, "scripts", "FindOranges.cmake"),
                                                start=OUTPUT_TREE_ROOT)

FINDER_DOC_FILE: Final[str] = os.path.join(OUTPUT_TREE_ROOT, "FindOranges.rst")
# editorconfig-checker-enable

with open(FINDER_DOC_FILE, "w", encoding="utf-8") as find_out:
	find_out.write(f".. cmake-module:: {FIND_ORANGES_PATH}")

del FIND_ORANGES_PATH

#

# Read content from the readme and write a UsingOranges.rst file

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

using_oranges_lines: list[str] = []

for line in readme_lines:
	if line.startswith(
	    "See the [``FindOranges``](scripts/FindOranges.cmake) file for more documentation on what it does."
	):
		using_oranges_lines.append(
		    f"\n:doc:`View the documentation for the FindOranges script <{os.path.splitext(os.path.relpath(FINDER_DOC_FILE, start=OUTPUT_TREE_ROOT))[0]}>`.\n"
		)
		continue

	if line.startswith("#"):
		STRIPPED_LINE: Final[str] = line.replace("#", "").strip()

		using_oranges_lines.append(f"\n{STRIPPED_LINE}\n")

		if STRIPPED_LINE == "Using Oranges":
			using_oranges_lines.append("-------------------------------\n")
		else:
			using_oranges_lines.append("##################\n")
	else:
		using_oranges_lines.append(f"{line}")

del readme_lines
del FINDER_DOC_FILE

# editorconfig-checker-disable
with open(os.path.join(OUTPUT_TREE_ROOT, "UsingOranges.rst"),
          "w",
          encoding="utf-8") as using_oranges:
	using_oranges.write("".join(using_oranges_lines))
# editorconfig-checker-enable

del using_oranges_lines
