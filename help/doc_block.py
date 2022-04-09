#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" doc_block.py
This module contains functions for parsing .rst documentation blocks found in CMake modules.
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

import paths
import printing

#

BEGIN: Final[str] = "#[=======================================================================[.rst:" # yapf: disable
END: Final[str] = "#]=======================================================================]" # yapf: disable

HEADING_MARKER: Final[str] = "-------------------------"
SECTION_MARKER: Final[str] = "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

COMMAND_MARKER: Final[str] = ".. command::"

#


def parse(module_full_path) -> list[str]:
	""" Parses the given CMake module for lines contained within a .rst documentation block """

	with open(module_full_path, "r", encoding="utf-8") as f:
		module_contents: Final[list[str]] = f.readlines()

	doc_lines: list[str] = []
	in_doc_block: bool = False

	for line in module_contents:
		if in_doc_block:
			if line.startswith(END):
				break

			if line.startswith(COMMAND_MARKER) or line.startswith(
			    HEADING_MARKER):
				continue

			doc_lines.append(line)

		elif line.startswith(BEGIN):
			in_doc_block = True

	return [line for line in doc_lines if line not in (None, "\n")]


#


def output(module_full_path, out_file=None, file_append=False) -> None: # yapf: disable
	""" Prints the contents of a .rst documentation block at the top of a CMake file.
		If out_file is not None, then the output will be written to the given filepath; otherwise, output is printed to the terminal.
	"""

	doc_lines: Final[list[str]] = parse(module_full_path)

	if out_file:
		if file_append:
			mode: Final[str] = "a"
		else:
			mode: Final[str] = "w"

		with open(out_file, mode, encoding="utf-8") as f:
			f.write("\n".join(doc_lines))

		module_name: Final[str] = paths.module_name_from_path(module_full_path)

		print(f"Help for module {module_name} has been written to: {out_file}")

		return

	print("")
	printing.section_heading(doc_lines.pop(0))

	for idx, line in enumerate(doc_lines):
		if line.startswith(SECTION_MARKER):
			continue

		if doc_lines[(idx+1) % len(doc_lines)].startswith(SECTION_MARKER):
			printing.section_heading(line)
		else:
			print(line)


#


def get_section(section_heading, module_lines) -> list[str]:
	""" Parses a documentation block for a subsection with the given heading """

	if not module_lines:
		return None

	in_section: bool = False

	section_lines: list[str] = []

	for idx, line in enumerate(module_lines):
		next_line: Final[str] = module_lines[(idx+1) % len(module_lines)]

		if in_section:
			if line.startswith(SECTION_MARKER):
				continue

			if next_line.startswith(SECTION_MARKER):
				break

			section_lines.append(line)

		elif line.startswith(section_heading) and next_line.startswith(
		    SECTION_MARKER):
			in_section = True

	return section_lines
