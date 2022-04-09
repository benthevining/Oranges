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
from collections import defaultdict

# TO DO:
# properties
# variables

#

ORANGES_MODULES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "modules") # yapf: disable

ORANGES_VERSION = "2.12.0"

#

DOC_BLOCK_BEGIN = "#[=======================================================================[.rst:"
DOC_BLOCK_END = "#]=======================================================================]"

DOC_HEADING_MARKER = "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

COMMAND_DOC_MARKER = ".. command::"

#


def get_module_list() -> list[str]:
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

	return list(set(full_paths))


#


def get_finders_list() -> list[str]:
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

	return list(set(full_paths))


#


def print_section_heading(text) -> None:
	""" Prints the line of text to the terminal, with ANSI bold and underline color codes applied """

	print(f"\033[1;30m\033[04m {text}\033[0m")


def print_error(text) -> None:
	""" Prints the line of text to the terminal, with ANSI bold and red color codes applied """

	print(f"\033[1;31m {text}\033[0m")


#


def print_cmake_doc_block(module_full_path, out_file=None) -> None:
	""" Prints the contents of a .rst documentation block at the top of a CMake file.
		If out_file is not None, then the output will be written to the given filepath; otherwise, output is printed to the terminal.
	"""

	with open(module_full_path, "r") as f:
		module_contents = f.readlines()

	doc_lines = []
	inDocBlock = False

	for line in module_contents:
		if inDocBlock:
			if line.startswith(DOC_BLOCK_END):
				break

			if line.startswith(COMMAND_DOC_MARKER) or line.startswith(
			    "-------------------------"):
				continue

			doc_lines.append(line)

		elif line.startswith(DOC_BLOCK_BEGIN):
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
		if line.startswith(DOC_HEADING_MARKER):
			continue

		if doc_lines[(idx+1) % len(doc_lines)].startswith(DOC_HEADING_MARKER):
			print_section_heading(line)
		else:
			print(line)


#


def print_module_help(module_name, error_string, out_file=None) -> None: # yapf: disable
	""" Prints help for the specified module. module_name should be just the filename of the module. """

	if not module_name.endswith(".cmake"):
		if not module_name.endswith("."):
			module_name += "."
		module_name += "cmake"

	path_list = get_module_list()
	path_list.extend(get_finders_list())

	module_full_path = None

	for fullPath in path_list:
		if os.path.basename(fullPath) == module_name:
			module_full_path = fullPath
			break

	if not module_full_path:
		print_error(error_string)
		sys.exit(1)

	print_cmake_doc_block(module_full_path, out_file)


#


def make_module_category_dict(module_paths) -> dict[list[str]]:
	""" Takes the list of full module paths and creates a dictionary where the keys are the category names and the values are a list of module names """

	module_categories = defaultdict(list)

	for module_path in list(set(module_paths)):
		folder_name = os.path.basename(os.path.dirname(module_path))
		category_name = folder_name.replace("_", " ").strip().capitalize()

		module_name = os.path.splitext(os.path.basename(module_path))[0]

		module_categories[category_name].append(module_name)

	for cat in module_categories:
		module_categories[cat].sort()

	return dict(sorted(module_categories.items()))


#



def print_module_list(kind, path_list, out_file=None, file_append=False) -> None: # yapf: disable
	""" Prints the categorized list of CMake modules of the specified kind (either modules or finders) """

	module_dict = make_module_category_dict(path_list)

	out_lines = []

	out_lines.append(f"Oranges provides the following {kind} modules:")
	out_lines.append("")

	for category in module_dict:
		out_lines.append(category)

		for module in module_dict[category]:
			out_lines.append(f"  * {module}")

		out_lines.append("")

	if out_file:
		if file_append:
			mode = "a"
		else:
			mode = "w"

		with open(out_file, mode) as f:
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
			print_section_heading(line)
		else:
			print("")


#


def list_all_commands(out_file=None) -> None:
	""" Prints the list of all commands provided by Oranges modules """

	commands = []

	for module in get_module_list():
		with open(module, "r") as f:
			module_lines = f.readlines()

		for line in module_lines:
			if line.startswith(COMMAND_DOC_MARKER):
				command = line.replace(COMMAND_DOC_MARKER, "")
				commands.append(command.strip())

	commands.sort()

	out_lines = []

	out_lines.append("Oranges provides the following CMake commands:")
	out_lines.append("")

	out_lines.extend(commands)

	if out_file:
		with open(out_file, "w") as f:
			f.write("\n".join(out_lines))

		print(f"The list of commands has been written to: {out_file}")
		return

	print("")
	print(out_lines.pop(0))

	for line in out_lines:
		print(line)


#


def get_file_containing_command(command_name) -> [list[str], str]:
	""" Finds the file containing the documentation for the given command, and returns its text and full path """

	for module in get_module_list():
		with open(module, "r") as f:
			module_lines = f.readlines()

		for line in module_lines:
			if line.startswith(COMMAND_DOC_MARKER):
				command = line.replace(COMMAND_DOC_MARKER, "").strip()

				if command == command_name:
					return module_lines, module

	return None


#


def print_command_help(command_name, out_file=None) -> None:
	""" Prints help for the given command """

	module_lines, module_path = get_file_containing_command(command_name)

	if not module_lines or not module_path:
		print_error(f"Error - invalid command name {command_name}")
		sys.exit(1)

	module_name = os.path.splitext(os.path.basename(module_path))[0]

	out_lines = [command_name]

	out_lines.append("")
	out_lines.append(f"Defined in module {module_name}")
	out_lines.append("")

	inDocBlock = False

	for idx, line in enumerate(module_lines):
		if inDocBlock:
			next_line = module_lines[(idx+1) % len(module_lines)]

			if next_line.startswith(
			    DOC_HEADING_MARKER) or next_line.startswith(DOC_BLOCK_END):
				break

			out_lines.append(line)

		elif line.startswith(COMMAND_DOC_MARKER):
			command = line.replace(COMMAND_DOC_MARKER, "").strip()

			if command == command_name:
				inDocBlock = True

	if out_file:
		with open(out_file, "w") as f:
			f.write("\n".join(out_lines))

		print(
		    f"Help for command {command_name} has been written to {out_file}")
		return

	print("")
	print_section_heading(out_lines.pop(0))

	for line in out_lines:
		print(line)


#


def print_basic_info(out_file=None) -> None:
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
		return

	for line in out_lines:
		print(line)


#


def main() -> None:

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

	parser.add_argument("--list-all-modules",
	                    "--all-modules",
	                    "-a",
	                    help="List all Cmake modules and find modules",
	                    action="store_true",
	                    dest="list_all")

	parser.add_argument("--list-modules",
	                    "--modules",
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
	                    "--finders",
	                    help="List all find modules Oranges ships",
	                    action="store_true",
	                    dest="list_finders")

	parser.add_argument("--find-module",
	                    "--finder",
	                    "-f",
	                    help="View help for the named find module",
	                    action="store",
	                    default=None,
	                    type=str,
	                    dest="find_module")

	parser.add_argument("--list-commands",
	                    "--commands",
	                    help="List all commands provided by Oranges modules",
	                    action="store_true",
	                    dest="list_commands")

	parser.add_argument("--command",
	                    "-c",
	                    help="View help for a specific command",
	                    action="store",
	                    default=None,
	                    type=str,
	                    dest="help_command")

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

	if args.list_all:
		print_module_list(out_file=args.out_file,
		                  kind="CMake",
		                  path_list=get_module_list())

		print_module_list(out_file=args.out_file,
		                  kind="find",
		                  path_list=get_finders_list(),
		                  file_append=True)

		sys.exit(0)

	if args.list_modules:
		print_module_list(out_file=args.out_file,
		                  kind="CMake",
		                  path_list=get_module_list())
		sys.exit(0)

	if args.list_finders:
		print_module_list(out_file=args.out_file,
		                  kind="find",
		                  path_list=get_finders_list())
		sys.exit(0)

	if args.help_module:
		print_module_help(
		    module_name=args.help_module,
		    out_file=args.out_file,
		    error_string=
		    "Error - nonexistent module requested! Use --list-modules to get the list of valid module names."
		)
		sys.exit(0)

	if args.find_module:
		find_module_name = args.find_module

		if not find_module_name.startswith("Find"):
			find_module_name = f"Find{find_module_name}"

		print_module_help(
		    module_name=find_module_name,
		    out_file=args.out_file,
		    error_string=
		    "Error - nonexistent find module requested! Use --list-find-modules to get the list of valid find module names."
		)
		sys.exit(0)

	if args.list_commands:
		list_all_commands(out_file=args.out_file)
		sys.exit(0)

	if args.help_command:
		print_command_help(command_name=args.help_command,
		                   out_file=args.out_file)
		sys.exit(0)


#

if __name__ == "__main__":
	main()
