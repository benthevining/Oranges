#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" targets.py
This module contains functions for listing and printing help about targets.
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


def print_help(target_name, out_file=None) -> None:
	""" Prints help for the given target """

	if target_name.startswith(
	    "Oranges") and not target_name.startswith("Oranges::"):
		target_name = f"Oranges::{target_name}"

	def get_file_containing_target() -> [list[str], str]:
		""" Finds the file containing the documentation for the given target, and returns its text and full path """

		for module in paths.get_module_list():
			with open(module, "r", encoding="utf-8") as f:
				module_lines: Final[list[str]] = f.readlines()

			for line in doc_block.get_section("Targets", module_lines):
				if line.startswith(f"- {target_name}"):
					return module_lines, module

		printing.error(f"Error - invalid target name {target_name}")
		raise FileNotFoundError(
		    f"Requested target {target_name} cannot be found!")

	#

	module_path: Final[str] = get_file_containing_target()[1]
	module_name: Final[str] = paths.module_name_from_path(module_path)

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
	printing.section_heading(out_lines.pop(0))

	for line in out_lines:
		print(line)

	doc_block.output(module_full_path=module_path,
	                 out_file=out_file,
	                 file_append=True)


#


def print_list(out_file=None) -> None:
	""" Prints a list of all targets defined by Oranges modules """

	targets: list[str] = []

	for module in paths.get_module_list():
		with open(module, "r", encoding="utf-8") as f:
			module_lines: Final[list[str]] = f.readlines()

		for line in doc_block.get_section("Targets", module_lines):
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
