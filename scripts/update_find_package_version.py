#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script searches a project source tree recursively for any occurrences of a CMake :external:command:`find_package()` or
:external:command:`find_dependency()` command for a specified package, and updates the version used in the :external:command:`find_package()` command
to a new one specified.
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


def process_file(package_name: str, new_version: str, file_path: str) -> bool:
	"""
	Processes a single file. Does nothing if the filename is not CMakelists.txt or the file extension is not .cmake.

	:param package_name: The package name whose version is being updated. This must be the exact name passed as the first argument to ``find_package()`` in CMake.
	:param new_version: The new version of the package. This can contain integers and ``.`` characters.
	:param file_path: The absolute path to the file to process.

	:returns: true if this file was changed.
	"""

	# pylint: disable=too-many-locals

	if not (os.path.splitext(file_path)[1] == ".cmake"
	        or os.path.basename(file_path) == "CMakeLists.txt"):
		return False

	with open(file_path, "r", encoding="utf-8") as file_in:
		file_lines: list[str] = file_in.readlines()

	anything_changed: bool = False

	for idx, line in enumerate(file_lines):
		stripped_line: Final[str] = line.strip()

		if not (stripped_line.startswith("find_package")
		        or stripped_line.startswith("FIND_PACKAGE")
		        or stripped_line.startswith("find_dependency")
		        or stripped_line.startswith("FIND_DEPENDENCY")):
			continue

		# this is another command that starts with find_package_
		if stripped_line[len("find_package"):].startswith("_"):
			continue

		find_pkg_args_string: Final[str] = stripped_line.split("(",
		                                                       1)[-1].split(
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

		file_lines[idx] = orig_chars_before_find_pkg_args + " ".join(
		    find_pkg_args) + ")\n"

		anything_changed = True

	if not anything_changed:
		return False

	print(f"Updating {file_path}")

	with open(file_path, "w", encoding="utf-8") as file_out:
		file_out.write("".join(file_lines))

	return True


#


# editorconfig-checker-disable
def process_directory(package_name: str, new_version: str,
                      dir_path: str) -> bool:
	"""
	Processes all CMake files in this directory recursively.

	:param package_name: The package name whose version is being updated. This must be the exact name passed as the first argument to ``find_package()`` in CMake.
	:param new_version: The new version of the package. This can contain integers and ``.`` characters.
	:param dir_path: The absolute path to the directory to process.

	:returns: true if any files in this directory were changed.
	"""

	# editorconfig-checker-enable

	any_files_changed: bool = False

	for entryname in os.listdir(dir_path):
		entry_path: Final[str] = os.path.join(dir_path, entryname)

		if os.path.isdir(entry_path):
			if entryname in ["Builds", "Cache"]:
				continue

			any_files_changed = process_directory(
			    package_name=package_name,
			    new_version=new_version,
			    dir_path=entry_path) or any_files_changed

		elif os.path.isfile(entry_path):
			any_files_changed = process_file(
			    package_name=package_name,
			    new_version=new_version,
			    file_path=entry_path) or any_files_changed

	return any_files_changed


#


# editorconfig-checker-disable
def update_find_package_version(package_name: str, new_version: str,
                                root_dir: str) -> bool:
	"""
	Scans all CMake files found in ``<root_dir>`` for occurrences of ``find_package(<package_name>)``, and updates them to use the ``<new_version>``
	specified.

	:param package_name: The package name whose version is being updated. This must be the exact name passed as the first argument to ``find_package()`` in CMake.
	:param new_version: The new version of the package. This can contain integers and ``.`` characters.
	:param root_dir: Path to the root directory to search. If this is not an absolute path, then the directory searched will be ``$(pwd)/<root_dir>``.

	:returns: true if any files were changed by this operation.
	"""

	if not os.path.isabs(root_dir):
		root_dir = os.path.join(os.getcwd(), root_dir)

	anything_changed: Final[bool] = process_directory(
	    package_name=package_name, new_version=new_version, dir_path=root_dir)

	if not anything_changed:
		print("All files up to date!")

	return anything_changed


# editorconfig-checker-enable

#


def _create_parser() -> ArgumentParser:
	"""
	Creates the argument parser for this script.

	:meta private:
	"""
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
	    "The new version of the package to be used with all find_package commands. This can contain integers and '.' characters."
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

	my_parser = _create_parser()

	if len(argv) < 2:
		my_parser.print_help()
	else:
		args = my_parser.parse_args()

		update_find_package_version(package_name=args.package_name,
		                            new_version=args.new_version,
		                            root_dir=args.root_dir)
