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

import sys
from argparse import ArgumentParser
from typing import Final

import commands
import paths
import targets

import modules

# TO DO:
# properties
# variables

#

ORANGES_VERSION: Final[str] = "2.14.0"

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
		with open(out_file, "w", encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"The version info has been written to: {out_file}")
		return

	for line in out_lines:
		print(line)


#


# editorconfig-checker-disable
# pylint: disable=too-many-arguments
def main(print_info=False,
         list_all=False,
         list_modules=False,
         list_finders=False,
         help_module=None,
         find_module=None,
         list_commands=False,
         help_command=None,
         list_targets=False,
         help_target=None,
         out_file=None) -> None:
	""" The main method.
		Only one action is actually taken; this method really exists as a wrapper for the command line invocations of the script.
	"""
	# editorconfig-checker-enable
	# pylint: disable=too-many-return-statements

	if print_info:
		print_basic_info(out_file)
		return

	if list_all:
		modules.print_full_list(out_file=out_file)

		return

	if list_modules:
		modules.print_list(out_file=out_file,
		                   kind="CMake",
		                   path_list=paths.get_module_list())
		return

	if list_finders:
		modules.print_list(out_file=out_file,
		                   kind="find",
		                   path_list=paths.get_finders_list())
		return

	if help_module:
		modules.print_help(module_name=help_module, out_file=out_file)
		return

	if find_module:
		modules.print_finder_help(module_name=find_module, out_file=out_file)
		return

	if list_commands:
		commands.print_list(out_file=out_file)
		return

	if help_command:
		commands.print_help(command_name=help_command, out_file=out_file)
		return

	if list_targets:
		targets.print_list(out_file=out_file)
		return

	if help_target:
		targets.print_help(target_name=help_target, out_file=out_file)
		return


#

if __name__ == "__main__":
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

	if len(sys.argv) == 1:
		parser.print_help(sys.stderr)
		sys.exit(1)

	args: Final = parser.parse_args()  # pylint: disable=invalid-name

	main(print_info=args.print_info,
	     list_all=args.list_all,
	     list_modules=args.list_modules,
	     list_finders=args.list_finders,
	     help_module=args.help_module,
	     find_module=args.find_module,
	     list_commands=args.list_commands,
	     help_command=args.help_command,
	     list_targets=args.list_targets,
	     help_target=args.help_target,
	     out_file=args.out_file)
