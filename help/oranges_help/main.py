#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script is the main entrypoint for the Oranges command line help tool.
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

import sys
from argparse import ArgumentParser
from typing import Final

from . import commands, modules, paths, targets


ORANGES_VERSION: Final[str] = "2.20.2"

#


def print_basic_info(out_file: str = None, file_append: bool = False) -> None:
	"""
	Prints the version and other basic information.
	"""

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
	out_lines.append(f"{paths.MODULES_DIR}")
	out_lines.append("")

	out_lines.append(
	    "The full path to the directory containing the Oranges find modules is:"
	)
	out_lines.append(f"{paths.FIND_MODULES_DIR}")
	out_lines.append("")

	out_lines.append(
	    "Oranges is free and open source software developed by Ben Vining, and distributed under the terms of the GNU Public License."
	)
	out_lines.append(
	    "View the source code at http://github.com/benthevining/Oranges.")
	out_lines.append("")

	if out_file:
		if file_append:
			mode: Final[str] = "a"
		else:
			mode: Final[str] = "w"

		with open(out_file, mode, encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"The version info has been written to: {out_file}")
		return

	for line in out_lines:
		print(line)


#


def main() -> None:
	"""
	The main method.
	"""

	# pylint: disable=too-many-return-statements

	parser = ArgumentParser(
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

	parser.add_argument(
	    "--file-append",
	    "--append",
	    help="Append to the output file instead of overwriting it",
	    action="store_true",
	    dest="file_append")

	if len(sys.argv) == 1:
		parser.print_help(sys.stderr)
		sys.exit(1)

	args: Final = parser.parse_args()

	if args.print_info:
		print_basic_info(out_file=args.out_file, file_append=args.file_append)
		return

	if args.list_all:
		modules.print_full_list(out_file=args.out_file,
		                        file_append=args.file_append)
		return

	if args.list_modules:
		modules.print_list(out_file=args.out_file,
		                   kind="CMake",
		                   path_list=paths.get_module_list(),
		                   file_append=args.file_append)
		return

	if args.list_finders:
		modules.print_list(out_file=args.out_file,
		                   kind="find",
		                   path_list=paths.get_finders_list(),
		                   file_append=args.file_append)
		return

	if args.help_module:
		modules.print_help(module_name=args.help_module,
		                   out_file=args.out_file,
		                   file_append=args.file_append)
		return

	if args.find_module:
		modules.print_finder_help(module_name=args.find_module,
		                          out_file=args.out_file,
		                          file_append=args.file_append)
		return

	if args.list_commands:
		commands.print_list(out_file=args.out_file,
		                    file_append=args.file_append)
		return

	if args.help_command:
		commands.print_help(command_name=args.help_command,
		                    out_file=args.out_file,
		                    file_append=args.file_append)
		return

	if args.list_targets:
		targets.print_list(out_file=args.out_file,
		                   file_append=args.file_append)
		return

	if args.help_target:
		targets.print_help(target_name=args.help_target,
		                   out_file=args.out_file,
		                   file_append=args.file_append)
		return


#

if __name__ == "__main__":
	main()
