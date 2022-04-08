#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

import argparse
import os
import sys

#
# commands
# properties
# variables

#

script_dir = os.path.dirname(os.path.realpath(__file__))

ORANGES_MODULES_DIR = os.path.join(os.path.dirname(script_dir), "modules")

ORANGES_VERSION = "2.11.0"

#


def get_module_list():
	""" Returns an array containing all the full paths to the Oranges CMake modules """

	child_dirs = next(os.walk(ORANGES_MODULES_DIR))[1]

	child_dirs.remove("finders")
	child_dirs.remove("internal")

	child_dirs.append(os.path.join("juce", "plugins"))

	full_paths = []

	for child_dir in child_dirs:
		child_dir_full_path = os.path.join(ORANGES_MODULES_DIR, child_dir)

		for child_file in next(os.walk(child_dir_full_path))[2]:
			if os.path.splitext(child_file)[1] == ".cmake":
				full_paths.append(os.path.join(child_dir_full_path,
				                               child_file))

	return full_paths


#


def get_finders_list():
	""" Returns an array containing all the full paths to the Oranges find modules """

	finders_dir = os.path.join(ORANGES_MODULES_DIR, "finders")

	child_dirs = next(os.walk(finders_dir))[1]

	child_dirs.append(os.path.join("libs", "FFTW"))

	full_paths = []

	for child_dir in child_dirs:
		child_dir_full_path = os.path.join(finders_dir, child_dir)

		for child_file in next(os.walk(child_dir_full_path))[2]:
			if child_file.startswith("Find") and os.path.splitext(
			    child_file)[1] == ".cmake":
				full_paths.append(os.path.join(child_dir_full_path,
				                               child_file))

	return full_paths


#


def print_section_heading(text):
	""" Prints the line of text to the terminal, with ANSI bold and underline color codes applied """

	print(f"\033[1;30m\033[04m {text}\033[0m")


#


def print_cmake_doc_block(module_full_path, out_file):
	""" Prints the contents of a .rst documentation block at the top of a CMake file.
		If out_file is not None, then the output will be written to the given filepath; otherwise, output is printed to the terminal.
	"""

	with open(module_full_path, "r") as f:
		module_contents = f.readlines()

	doc_lines = []
	inDocBlock = False

	for line in module_contents:
		if inDocBlock:
			if line.startswith(
			    "#]=======================================================================]"
			):
				break

			doc_lines.append(line)

		elif line.startswith(
		    "#[=======================================================================[.rst:"
		):
			inDocBlock = True

	doc_lines = [line for line in doc_lines if line not in (None, "\n")]

	if out_file:
		with open(out_file, "w") as f:
			f.write("\n".join(doc_lines))

		module_name = os.path.splitext(os.path.basename(module_full_path))[0]
		print(f"Help for module {module_name} has been written to: {out_file}")

		return

	print("")

	print_section_heading(doc_lines.pop(0))

	for idx, line in enumerate(doc_lines):
		if line.startswith("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"):
			continue

		if doc_lines[(idx+1) % len(doc_lines)].startswith(
		    "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"):
			print_section_heading(line)
		else:
			print(line)


#


def print_error(error_msg):
	""" Prints the given text to the terminal in bold red """

	print(f"\033[1;31m {error_msg}\033[0m")


#


def print_module_help(module_name, out_file):
	""" Prints help for the specified module. module_name should be just the filename of the module. """

	if not module_name.endswith(".cmake"):
		if not module_name.endswith("."):
			module_name += "."
		module_name += "cmake"

	module_full_path = None

	for fullPath in get_module_list():
		if os.path.basename(fullPath) == module_name:
			module_full_path = fullPath
			break

	if not module_full_path:
		print_error(
		    "Error - nonexistent module requested! Use --list-modules to get the list of valid module names."
		)
		sys.exit(1)

	print_cmake_doc_block(module_full_path, out_file)


#


def print_finder_help(module_name, out_file):
	""" Prints help for the specified find module. module_name should be just the filename of the module. """

	if not module_name.endswith(".cmake"):
		if not module_name.endswith("."):
			module_name += "."
		module_name += "cmake"

	module_full_path = None

	for fullPath in get_finders_list():
		if os.path.basename(fullPath) == module_name:
			module_full_path = fullPath
			break

	if not module_full_path:
		print_error(
		    "Error - nonexistent find module requested! Use --list-find-modules to get the list of valid find module names."
		)
		sys.exit(1)

	print_cmake_doc_block(module_full_path, out_file)


#


def print_module_list(out_file):
	""" Prints the list of CMake modules Oranges provides """

	module_names = []

	for module_path in get_module_list():
		module_names.append(os.path.splitext(os.path.basename(module_path))[0])

	module_names.sort()

	if out_file:
		with open(out_file, "w") as f:
			f.write("\n".join(module_names))
		print(f"The list of CMake modules has been written to: {out_file}")
	else:
		for module_name in module_names:
			print(module_name)


#


def print_finders_list(out_file):
	""" Prints the list of find modules Oranges provides """

	module_names = []

	for module_path in get_finders_list():
		module_names.append(os.path.splitext(os.path.basename(module_path))[0])

	module_names.sort()

	if out_file:
		with open(out_file, "w") as f:
			f.write("\n".join(module_names))
		print(f"The list of find modules has been written to: {out_file}")
	else:
		for module_name in module_names:
			print(module_name)


#


def print_basic_info(out_file):
	""" Prints the version and other basic information """

	out_lines = [
	    "",
	    " ======================================================================================",
	    "    ____  _____            _   _  _____ ______  _____",
	    "   / __ \\|  __ \\     /\\   | \\ | |/ ____|  ____|/ ____|",
	    "  | |  | | |__) |   /  \\  |  \\| | |  __| |__  | (___",
	    "  | |  | |  _  /   / /\\ \\ | . ` | | |_ |  __|  \\___ \\",
	    "  | |__| | | \\ \\  / ____ \\| |\\  | |__| | |____ ____) |",
	    "   \\____/|_|  \\_\\/_/    \\_\\_| \\_|\\_____|______|_____/", "",
	    " ======================================================================================",
	    ""
	]

	out_lines.append(f"Version {ORANGES_VERSION}")
	out_lines.append("")

	out_lines.append(
	    "The full path to the directory containing the Oranges CMake modules is:"
	)
	out_lines.append(f"{ORANGES_MODULES_DIR}")
	out_lines.append("")

	out_lines.append(
	    "Oranges is free and open source software developed by Ben Vining.")
	out_lines.append(
	    "View the source code at http://github.com/benthevining/Oranges.")
	out_lines.append("")

	if out_file:
		with open(out_file, "w") as f:
			f.write("\n".join(out_lines))
		print(f"The version info has been written to: {out_file}")
	else:
		for line in out_lines:
			print(line)


#


def main():
	parser = argparse.ArgumentParser(
	    description="Oranges help",
	    epilog=
	    "Oranges is free and open source software developed by Ben Vining. View the source code at http://github.com/benthevining/Oranges."
	)

	parser.add_argument("--version",
	                    "--info",
	                    "-v",
	                    "-i",
	                    help="Print version and other basic information",
	                    action="store_true",
	                    dest="print_info")

	parser.add_argument("--list-modules",
	                    help="List all Oranges CMake modules",
	                    action="store_true",
	                    dest="list_modules")

	parser.add_argument("--module",
	                    "-m",
	                    help="View help for the named CMake module",
	                    action="store",
	                    default=None,
	                    type=str,
	                    dest="help_module")

	parser.add_argument("--list-find-modules",
	                    help="List all find modules Oranges ships",
	                    action="store_true",
	                    dest="list_finders")

	parser.add_argument("--finder",
	                    "--find-module",
	                    "-f",
	                    help="View help for the named find module",
	                    action="store",
	                    default=None,
	                    type=str,
	                    dest="find_module")

	parser.add_argument("--file",
	                    "--output",
	                    "-o",
	                    help="Write the help output to the given file",
	                    action="store",
	                    default=None,
	                    type=str,
	                    dest="out_file")

	if len(sys.argv) == 1:
		parser.print_help(sys.stderr)
		sys.exit(1)

	args = parser.parse_args()

	if args.print_info:
		print_basic_info(args.out_file)
		sys.exit(0)

	if args.list_modules:
		print_module_list(args.out_file)
		sys.exit(0)

	if args.list_finders:
		print_finders_list(args.out_file)
		sys.exit(0)

	if args.help_module:
		print_module_help(args.help_module, args.out_file)
		sys.exit(0)

	if args.find_module:
		print_finder_help(args.find_module, args.out_file)
		sys.exit(0)


#

if __name__ == "__main__":
	main()
