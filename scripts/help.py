#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" Oranges help script

This script is a simple command line interface providing quick reference for Oranges, similar to CMake's CLI help functionality.
You can use this script to list or view help for Oranges modules, commands, or targets.
Any output from this script can also be dumped to a file.
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

import argparse
import os
import sys
from collections import defaultdict
from typing import Final

# TO DO:
# properties
# variables

#

ORANGES_MODULES_DIR: Final[str] = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "modules") # yapf: disable

ORANGES_FIND_MODULES_DIR: Final[str] = os.path.join(ORANGES_MODULES_DIR, "finders") # yapf: disable

ORANGES_VERSION: Final[str] = "2.14.0"

#

DOC_BLOCK_BEGIN: Final[str] = "#[=======================================================================[.rst:" # yapf: disable
DOC_BLOCK_END: Final[str] = "#]=======================================================================]" # yapf: disable

DOC_HEADING_MARKER: Final[str] = "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

COMMAND_DOC_MARKER: Final[str] = ".. command::"

#


def get_module_list() -> list[str]:
	""" Returns an array containing all the full paths to the Oranges CMake modules """

	child_dirs: list[str] = next(os.walk(ORANGES_MODULES_DIR))[1]

	child_dirs.remove("finders")
	child_dirs.remove("internal")

	child_dirs.append(os.path.join("juce", "plugins"))

	full_paths: list[str] = []

	for child_dir in child_dirs:
		child_dir_full_path: Final[str] = os.path.join(ORANGES_MODULES_DIR,
		                                               child_dir)

		for child_file in next(os.walk(child_dir_full_path))[2]:
			if os.path.splitext(child_file)[1] == ".cmake":
				full_paths.append(os.path.join(child_dir_full_path,
				                               child_file))

	return list(set(full_paths))


#


def get_finders_list() -> list[str]:
	""" Returns an array containing all the full paths to the Oranges find modules """

	child_dirs: list[str] = next(os.walk(ORANGES_FIND_MODULES_DIR))[1]

	child_dirs.append(os.path.join("libs", "FFTW"))

	full_paths: list[str] = []

	for child_dir in child_dirs:
		child_dir_full_path: Final[str] = os.path.join(
		    ORANGES_FIND_MODULES_DIR, child_dir)

		for child_file in next(os.walk(child_dir_full_path))[2]:
			if child_file.startswith("Find") and os.path.splitext(
			    child_file)[1] == ".cmake":
				full_paths.append(os.path.join(child_dir_full_path,
				                               child_file))

	return list(set(full_paths))


#


def module_name_from_path(full_path) -> str:
	""" Returns the name of a module from its full filepath """

	return os.path.splitext(os.path.basename(full_path))[0]


def module_path_from_name(module_name) -> str:
	""" Returns the full path of a module from its name """

	path_list: list[str] = get_module_list()
	path_list.extend(get_finders_list())

	for full_path in path_list:
		if os.path.basename(full_path) == module_name:
			return full_path

	return None


#


def print_section_heading(text) -> None:
	""" Prints the line of text to the terminal, with ANSI bold and underline color codes applied """

	print(f"\033[1;30m\033[04m {text}\033[0m")


def print_error(text) -> None:
	""" Prints the line of text to the terminal, with ANSI bold and red color codes applied """

	print(f"\033[1;31m {text}\033[0m")


#


def print_cmake_doc_block(module_full_path, out_file=None, file_append=False) -> None: # yapf: disable
	""" Prints the contents of a .rst documentation block at the top of a CMake file.
		If out_file is not None, then the output will be written to the given filepath; otherwise, output is printed to the terminal.
	"""

	with open(module_full_path, "r", encoding="utf-8") as f:
		module_contents: Final[list[str]] = f.readlines()

	doc_lines: list[str] = []
	in_doc_block: bool = False

	for line in module_contents:
		if in_doc_block:
			if line.startswith(DOC_BLOCK_END):
				break

			if line.startswith(COMMAND_DOC_MARKER) or line.startswith(
			    "-------------------------"):
				continue

			doc_lines.append(line)

		elif line.startswith(DOC_BLOCK_BEGIN):
			in_doc_block = True

	del module_contents
	del in_doc_block

	doc_lines: Final[list[str]] = [
	    line for line in doc_lines if line not in (None, "\n")
	]

	if out_file:
		if file_append:
			mode: Final[str] = "a"
		else:
			mode: Final[str] = "w"

		with open(out_file, mode, encoding="utf-8") as f:
			f.write("\n".join(doc_lines))

		module_name: Final[str] = module_name_from_path(module_full_path)

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

	module_full_path: Final[str] = module_path_from_name(module_name)

	if not module_full_path:
		print_error(error_string)
		sys.exit(1)

	print_cmake_doc_block(module_full_path, out_file)


#


def print_module_list(kind, path_list, out_file=None, file_append=False) -> None: # yapf: disable
	""" Prints the categorized list of CMake modules of the specified kind (either modules or finders) """

	def make_module_category_dict() -> dict[list[str]]:
		""" Takes the list of full module paths and creates a dictionary where the keys are the category names and the values are a list of module names """

		module_categories: dict[list[str]] = defaultdict(list[str])

		for module_path in list(set(path_list)):
			folder_name: Final[str] = os.path.basename(
			    os.path.dirname(module_path))
			category_name: Final[str] = folder_name.replace(
			    "_", " ").strip().capitalize()

			del folder_name

			module_name: Final[str] = module_name_from_path(module_path)

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
			print_section_heading(line)
		else:
			print("")


#


def list_all_commands(out_file=None) -> None:
	""" Prints the list of all commands provided by Oranges modules """

	commands: list[str] = []

	for module in get_module_list():
		with open(module, "r", encoding="utf-8") as f:
			module_lines: Final[list[str]] = f.readlines()

		for line in module_lines:
			if line.startswith(COMMAND_DOC_MARKER):
				commands.append(line.replace(COMMAND_DOC_MARKER, "").strip())

	commands.sort()

	out_lines: list[str] = []

	out_lines.append("Oranges provides the following CMake commands:")
	out_lines.append("")

	out_lines.extend(commands)

	del commands

	if out_file:
		with open(out_file, "w", encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"The list of commands has been written to: {out_file}")
		return

	print("")
	print(out_lines.pop(0))

	for line in out_lines:
		print(line)


#


def print_command_help(command_name, out_file=None) -> None:
	""" Prints help for the given command """

	def get_file_containing_command() -> [list[str], str]:
		""" Finds the file containing the documentation for the given command, and returns its text and full path """

		for module in get_module_list():
			with open(module, "r", encoding="utf-8") as f:
				module_lines: Final[list[str]] = f.readlines()

			for line in module_lines:
				if line.startswith(COMMAND_DOC_MARKER):
					if line.replace(COMMAND_DOC_MARKER,
					                "").strip() == command_name:
						return module_lines, module

		print_error(f"Error - invalid command name {command_name}")
		sys.exit(1)

	#

	module_lines, module_path = get_file_containing_command()

	module_name: Final[str] = module_name_from_path(module_path)

	del module_path

	out_lines: list[str] = [command_name]

	out_lines.append("")
	out_lines.append(f"Defined in module {module_name}")
	out_lines.append("")

	del module_name

	in_doc_block: bool = False

	for idx, line in enumerate(module_lines):
		if in_doc_block:
			next_line: Final[str] = module_lines[(idx+1) % len(module_lines)]

			if next_line.startswith(
			    DOC_HEADING_MARKER) or next_line.startswith(DOC_BLOCK_END):
				break

			out_lines.append(line)

		elif line.startswith(COMMAND_DOC_MARKER):
			if line.replace(COMMAND_DOC_MARKER, "").strip() == command_name:
				in_doc_block = True

	del module_lines
	del in_doc_block

	if out_file:
		with open(out_file, "w", encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(
		    f"Help for command {command_name} has been written to {out_file}")

		return

	print("")
	print_section_heading(out_lines.pop(0))

	for line in out_lines:
		print(line)


#


def get_section_of_doc_block(section_heading, module_lines) -> list[str]:
	""" Parses a documentation block for a subsection with the given heading """

	if not module_lines:
		return None

	in_section: bool = False

	section_lines: list[str] = []

	for idx, line in enumerate(module_lines):
		next_line: Final[str] = module_lines[(idx+1) % len(module_lines)]

		if in_section:
			if line.startswith(DOC_HEADING_MARKER):
				continue

			if next_line.startswith(DOC_HEADING_MARKER):
				break

			section_lines.append(line)

		elif line.startswith(section_heading) and next_line.startswith(
		    DOC_HEADING_MARKER):
			in_section = True

	return section_lines


#


def list_all_targets(out_file=None) -> None:
	""" Prints a list of all targets defined by Oranges modules """

	targets: list[str] = []

	for module in get_module_list():
		with open(module, "r", encoding="utf-8") as f:
			module_lines: Final[list[str]] = f.readlines()

		for line in get_section_of_doc_block("Targets", module_lines):
			if line.startswith("-"):
				targets.append(line.replace("-", "").strip())

	util_targets: list[str] = []
	proj_targets: list[str] = []

	for target in targets:
		if target.startswith("Oranges::"):
			util_targets.append(target)
		else:
			proj_targets.append(target)

	del targets

	util_targets.sort()

	for target in util_targets:
		target = f"Oranges::{target}"

	out_lines: list[str] = []

	out_lines.append("Oranges provides the following utility targets:")
	out_lines.append("")

	for target in util_targets:
		out_lines.append(target)

	del util_targets

	out_lines.append("")
	out_lines.append(
	    "And the following targets are created on a per-project basis, by inclusion of various modules:"
	)
	out_lines.append("")

	for target in proj_targets:
		out_lines.append(target)

	del proj_targets

	if out_file:
		with open(out_file, "w", encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"The list of targets has been written to: {out_file}")
		return

	print("")
	print(out_lines.pop(0))

	for line in out_lines:
		print(line)


#


def print_target_help(target_name, out_file=None) -> None:
	""" Prints help for the given target """

	def get_file_containing_target() -> [list[str], str]:
		""" Finds the file containing the documentation for the given target, and returns its text and full path """

		for module in get_module_list():
			with open(module, "r", encoding="utf-8") as f:
				module_lines: Final[list[str]] = f.readlines()

			for line in get_section_of_doc_block("Targets", module_lines):
				if line.startswith(f"- {target_name}"):
					return module_lines, module

		print_error(f"Error - invalid target name {target_name}")
		sys.exit(1)

	#

	module_path: Final[str] = get_file_containing_target()[1]
	module_name: Final[str] = module_name_from_path(module_path)

	out_lines: list[str] = [target_name]

	out_lines.append("")
	out_lines.append(f"Defined in module {module_name}")
	out_lines.append("")

	del module_name

	if out_file:
		with open(out_file, "w", encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"Help for target {target_name} has been written to {out_file}")

		return

	print("")
	print_section_heading(out_lines.pop(0))

	for line in out_lines:
		print(line)

	print_cmake_doc_block(module_full_path=module_path,
	                      out_file=out_file,
	                      file_append=True)


#


def print_basic_info(out_file=None) -> None:
	""" Prints the version and other basic information """

	out_lines: list[str] = [
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
	    "The full path to the directory containing the Oranges find modules is:"
	)
	out_lines.append(f"{ORANGES_FIND_MODULES_DIR}")
	out_lines.append("")

	out_lines.append(
	    "Oranges is free and open source software developed by Ben Vining, and distributed under the terms of the GNU Public License."
	)
	out_lines.append(
	    "View the source code at http://github.com/benthevining/Oranges.")
	out_lines.append("")

	if out_file:
		with open(out_file, "w", encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"The version info has been written to: {out_file}")
		return

	for line in out_lines:
		print(line)


#


def main() -> None:
	""" The main method """

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
	                    help="List all Oranges Cmake modules and find modules",
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

	parser.add_argument("--list-targets",
	                    "--targets",
	                    help="List all targets defined by Oranges modules",
	                    action="store_true",
	                    dest="list_targets")

	parser.add_argument("--target",
	                    "-t",
	                    help="View help for a specific target",
	                    action="store",
	                    default=None,
	                    type=str,
	                    dest="help_target")

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

	args: Final = parser.parse_args()

	del parser

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

	if args.list_targets:
		list_all_targets(out_file=args.out_file)
		sys.exit(0)

	if args.help_target:
		target: str = args.help_target

		if target.startswith("Oranges") and not target.startswith("Oranges::"):
			target = f"Oranges::{target}"

		print_target_help(target_name=target, out_file=args.out_file)
		sys.exit(0)


#

if __name__ == "__main__":
	main()
