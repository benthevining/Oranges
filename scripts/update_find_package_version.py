#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script searches a project source tree recursively for any occurrences of a CMake find_package() command for a specified package, and updates the
version used in the find_package() command to a new one specified.
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


def process_file(package_name: str, new_version: str, file_path: str):
	"""
	Processes a single CMake file.
	"""

	# pylint: disable=too-many-locals

	if not (os.path.splitext(file_path)[1]
	        == ".cmake") or (os.path.basename(file_path) == "CMakeLists.txt"):
		return

	with open(file_path, "r", encoding="utf-8") as file_in:
		file_lines: list[str] = file_in.readlines()

	anything_changed: bool = False

	for idx, line in enumerate(file_lines):
		stripped_line: Final[str] = line.strip()

		if not (stripped_line.startswith("find_package")
		        or stripped_line.startswith("FIND_PACKAGE")):
			continue

		# this is another command that starts with find_package_
		if stripped_line[len("find_package"):].startswith("_"):
			continue

		find_pkg_args_string: Final[str] = stripped_line.split("(",
		                                                       1)[1].split(
		                                                           ")", 1)[0]

		del stripped_line

		find_pkg_args: list[str] = find_pkg_args_string.split()

		orig_chars_before_find_pkg_args: Final[str] = line.split(
		    find_pkg_args_string, 1)[0]

		del find_pkg_args_string

		if not find_pkg_args[0].strip() == package_name:
			continue

		# check if a version was given, and if it matches the new version already

		find_pkg_version: Final[str] = find_pkg_args[1].strip()

		version_was_given: Final[bool] = find_pkg_version.replace(
		    ".", "").isdigit()

		if version_was_given:
			if find_pkg_version == new_version:
				continue

		del find_pkg_version

		# either replace the given version, or insert it and scoot other args back

		if version_was_given:
			find_pkg_args[1] = new_version
		else:
			find_pkg_args.insert(1, new_version)

		new_find_pkg_args_str: Final[str] = " ".join(find_pkg_args)

		del find_pkg_args

		file_lines[
		    idx] = orig_chars_before_find_pkg_args + new_find_pkg_args_str

		anything_changed = True

	if anything_changed:
		with open(file_path, "w", encoding="utf-8") as file_out:
			file_out.write("".join(file_lines))


#


def process_directory(package_name: str, new_version: str, dir_path: str):
	"""
	Processes all CMake files in this directory recursively.
	"""

	for entryname in os.listdir(dir_path):
		entry_path: Final[str] = os.path.join(dir_path, entryname)

		if os.path.isdir(entry_path):
			process_directory(package_name=package_name,
			                  new_version=new_version,
			                  dir_path=entry_path)
		elif os.path.isfile(entry_path):
			process_file(package_name=package_name,
			             new_version=new_version,
			             file_path=entry_path)


#


# editorconfig-checker-disable
def update_find_package_version(package_name: str, new_version: str,
                                root_dir: str):
	"""
	Scans all CMake files found in <root_dir> for occurrences of find_package(<package_name>), and updates them to use the <new_version> specified.
	"""

	if not os.path.isabs(root_dir):
		root_dir = os.path.join(os.getcwd(), root_dir)

	process_directory(package_name=package_name,
	                  new_version=new_version,
	                  dir_path=root_dir)


# editorconfig-checker-enable

#

if __name__ == "__main__":
	from argparse import ArgumentParser
	from sys import argv

	parser = ArgumentParser()

	parser.add_argument(
	    "--package",
	    "-p",
	    action="store",
	    dest="package_name",
	    required=True,
	    help=
	    "Name of the package to update the version of. This must be the exact string passed as the first argument to find_package()."
	)

	parser.add_argument(
	    "--version",
	    "-v",
	    action="store",
	    dest="new_version",
	    required=True,
	    help=
	    "The new version of the package to be used with all find_package commands."
	)

	parser.add_argument(
	    "--root",
	    "-r",
	    action="store",
	    dest="root_dir",
	    required=True,
	    help="Root directory to scan for CMake files to change")

	if len(argv) < 2:
		parser.print_help()
	else:
		args = parser.parse_args()

		update_find_package_version(package_name=args.package_name,
		                            new_version=args.new_version,
		                            root_dir=args.root_dir)
