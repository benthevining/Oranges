#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" commands.py
This module contains functions for listing and printing help about CMake commands.
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

from . import doc_block, paths, printing

#


def print_help(command_name, out_file=None) -> None:
	""" Prints help for the given command """

	def get_file_containing_command() -> [list[str], str]:
		""" Finds the file containing the documentation for the given command, and returns its text and full path """

		for module in paths.get_module_list():
			with open(module, "r", encoding="utf-8") as f:
				module_lines: Final[list[str]] = f.readlines()

			for line in module_lines:
				if line.startswith(doc_block.COMMAND_MARKER):
					if line.replace(doc_block.COMMAND_MARKER,
					                "").strip() == command_name:
						return module_lines, module

		printing.error(f"Error - invalid command name {command_name}")
		raise RuntimeError(f"Requested command {module_name} cannot be found!")

	#

	module_lines, module_path = get_file_containing_command()

	module_name: Final[str] = paths.module_name_from_path(module_path)

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
			    doc_block.SECTION_MARKER) or next_line.startswith(
			        doc_block.END):
				break

			out_lines.append(line)

		elif line.startswith(doc_block.COMMAND_MARKER):
			if line.replace(doc_block.COMMAND_MARKER,
			                "").strip() == command_name:
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
	printing.section_heading(out_lines.pop(0))

	for line in out_lines:
		print(line)


#


def print_list(out_file=None) -> None:
	""" Prints the list of all commands provided by Oranges modules """

	commands: list[str] = []

	for module in paths.get_module_list():
		with open(module, "r", encoding="utf-8") as f:
			module_lines: Final[list[str]] = f.readlines()

		for line in module_lines:
			if line.startswith(doc_block.COMMAND_MARKER):
				commands.append(
				    line.replace(doc_block.COMMAND_MARKER, "").strip())

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
