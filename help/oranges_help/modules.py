#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" modules.py
This module contains functions for listing and printing help about CMake modules.
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

from collections import defaultdict
from os import path
from typing import Final

from . import doc_block, paths, printing

#

def print_finder_help(module_name: str, out_file: str=None) -> None: # yapf: disable
	""" Prints help for the specified find module. """

	if not module_name.startswith("Find"):
		module_name = f"Find{module_name}"

	print_help(
	    module_name=module_name,
	    out_file=out_file,
	    error_string=
	    "Error - nonexistent find module requested! Use --list-find-modules to get the list of valid find module names."
	)


#


# editorconfig-checker-disable
def print_help(
    module_name: str,
    out_file: str = None,
    error_string:
    str = "Error - nonexistent module requested! Use --list-modules to get the list of valid module names."
) -> None:
	""" Prints help for the specified module. """
	# editorconfig-checker-enable

	if not module_name.endswith(".cmake"):
		if not module_name.endswith("."):
			module_name += "."
		module_name += "cmake"

	module_full_path: Final[str] = paths.module_path_from_name(module_name)

	if not module_full_path:
		printing.error(error_string)
		raise FileNotFoundError(
		    f"Requested module {module_name} cannot be found!")

	doc_block.output(module_full_path, out_file)


#

def print_list(kind: str, path_list: list[str], out_file: str=None, file_append: bool=False) -> None: # yapf: disable
	""" Prints the categorized list of CMake modules of the specified kind (either modules or finders) """

	def make_module_category_dict() -> dict[list[str]]:
		""" Takes the list of full module paths and creates a dictionary where the keys are the category names and the values are a list of module names """

		module_categories: dict[list[str]] = defaultdict(list[str])

		for module_path in list(set(path_list)):
			folder_name: Final[str] = path.basename(path.dirname(module_path))
			category_name: Final[str] = folder_name.replace(
			    "_", " ").strip().capitalize()

			del folder_name

			module_name: Final[str] = paths.module_name_from_path(module_path)

			module_categories[category_name].append(module_name)

		for cat in module_categories:
			module_categories[cat].sort()

		return dict(sorted(module_categories.items()))

	#

	module_dict: Final[dict[list[str]]] = make_module_category_dict()

	out_lines: list[str] = []

	out_lines.append(f"Oranges provides the following {kind} modules:")
	out_lines.append("")

	for category in module_dict:
		out_lines.append(category)

		for module in module_dict[category]:
			out_lines.append(f"  * {module}")

		out_lines.append("")

	del module_dict

	if out_file:
		if file_append:
			mode: str = "a"
		else:
			mode: str = "w"

		with open(out_file, mode, encoding="utf-8") as f:
			if file_append:
				f.write("\n")

			f.write("\n".join(out_lines))

		print(f"The list of {kind} modules has been written to: {out_file}")
		return

	print("")
	print(out_lines.pop(0))

	for line in out_lines:
		if line.startswith("  *"):
			print(line)
		elif line:
			printing.section_heading(line)
		else:
			print("")


#


def print_full_list(out_file: str = None) -> None:
	""" Prints the full list of CMake modules and find modules that Oranges provides """

	print_list(out_file=out_file,
	           kind="CMake",
	           path_list=paths.get_module_list())

	print_list(out_file=out_file,
	           kind="find",
	           path_list=paths.get_finders_list(),
	           file_append=True)
