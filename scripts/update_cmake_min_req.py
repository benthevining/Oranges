#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script searches a project source tree for all CMake files, and updates the :external:command:`cmake_minimum_required()` version in each of them.
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
from argparse import ArgumentParser
import os

#


def process_file(new_version: str, file_path: str) -> bool:
	"""
	Processes a single file. Does nothing if the filename is not CMakelists.txt or the file extension is not .cmake.

	:param new_version: The new minimum version of CMake to require. This can contain integers and ``.`` characters.
	:param file_path: The absolute path to the file to process.

	:returns: true if this file was changed.
	"""

	if not (os.path.splitext(file_path)[1] == ".cmake"
	        or os.path.basename(file_path) == "CMakeLists.txt"):
		return False

	with open(file_path, "r", encoding="utf-8") as file_in:
		file_lines: list[str] = file_in.readlines()

	anything_changed: bool = False

	for idx, line in enumerate(file_lines):
		stripped_line: Final[str] = line.strip()

		if not (stripped_line.startswith("cmake_minimum_required")
		        or stripped_line.startswith("CMAKE_MINIMUM_REQUIRED")):
			continue

		orig_args_string: Final[str] = stripped_line.split("(", 1)[-1].split(
		    ")", 1)[0]

		del stripped_line

		args_list: list[str] = orig_args_string.split()

		orig_chars_before_orig_args: Final[str] = line.split(
		    orig_args_string, 1)[0]

		del orig_args_string

		version_pos: Final[int] = args_list.index("VERSION") + 1

		if args_list[version_pos] == new_version:
			continue

		args_list[version_pos] = new_version

		file_lines[idx] = orig_chars_before_orig_args + " ".join(
		    args_list) + ")\n"

		anything_changed = True

	if not anything_changed:
		return False

	print(f"Updating {file_path}")

	with open(file_path, "w", encoding="utf-8") as file_out:
		file_out.write("".join(file_lines))

	return True


#


def process_directory(new_version: str, dir_path: str) -> bool:
	"""
	Processes all CMake files in this directory recursively.

	:param new_version: The new minimum version of CMake to require. This can contain integers and ``.`` characters.
	:param dir_path: The absolute path to the directory to process.

	:returns: true if any files in this directory were changed.
	"""

	any_files_changed: bool = False

	for entryname in os.listdir(dir_path):
		entry_path: Final[str] = os.path.join(dir_path, entryname)

		if os.path.isdir(entry_path):
			if entryname in ["Builds", "Cache"]:
				continue

			any_files_changed = process_directory(
			    new_version=new_version,
			    dir_path=entry_path) or any_files_changed

		elif os.path.isfile(entry_path):
			any_files_changed = process_file(
			    new_version=new_version,
			    file_path=entry_path) or any_files_changed

	return any_files_changed


#


def update_cmake_min_req(new_version: str, root_dir: str) -> bool:
	"""
	Scans all CMake files found in ``<root_dir>`` for occurrences of ``cmake_minimum_required()``, and updates them to use the ``<new_version>``
	specified.

	:param new_version: The new minimum version of CMake to require. This can contain integers and ``.`` characters.
	:param root_dir: Path to the root directory to search. If this is not an absolute path, then the directory searched will be ``$(pwd)/<root_dir>``.

	:returns: true if any files were changed by this operation.
	"""

	if not os.path.isabs(root_dir):
		root_dir = os.path.join(os.getcwd(), root_dir)

	anything_changed: Final[bool] = process_directory(new_version=new_version,
	                                                  dir_path=root_dir)

	if not anything_changed:
		print("All files up to date!")

	return anything_changed


#


def __create_parser() -> ArgumentParser:
	"""
	Creates the argument parser for this script.

	:meta private:
	"""
	parser = ArgumentParser()

	parser.add_argument(
	    "--version",
	    "-v",
	    action="store",
	    dest="new_version",
	    required=True,
	    help=
	    "The new minimum version of CMake to require. This can contain integers and ``.`` characters."
	)

	parser.add_argument(
	    "--root",
	    "-r",
	    action="store",
	    dest="root_dir",
	    required=True,
	    help=
	    "Root directory to scan for CMake files to change. If this is not an absolute path, then the directory searched will be ``$(pwd)/<root_dir>``."
	)

	return parser


#

if __name__ == "__main__":
	from sys import argv

	my_parser = __create_parser()

	if len(argv) < 2:
		my_parser.print_help()
	else:
		args = my_parser.parse_args()

		update_cmake_min_req(new_version=args.new_version,
		                     root_dir=args.root_dir)
