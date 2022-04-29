#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This module contains functions for listing and printing help about CMake properties.

The information is read from the file data/properties.json, which is generated by running CMake on the Oranges source tree.
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
from os import path
from json import load as load_json
from sys import exit as exit_program
from . import printing

#

try:
	with open(path.join(path.dirname(__file__), "data/properties.json"), "r", encoding="utf-8") as json:
		PROPERTIES_JSON : Final = load_json(json)
except FileNotFoundError:
	print("ERROR: data/properties.json file not found. Did you run CMake on Oranges before invoking this script?")
	exit_program(1)

#

def print_list(out_file: str = None, file_append: bool = False) -> None:
	"""
	Prints a list of all CMake properties defined by Oranges.
	"""

	target_props: list[str] = []
	global_props: list[str] = []

	for prop in PROPERTIES_JSON["properties"]:
		if prop["kind"] == "GLOBAL":
			global_props.append(prop["name"])
		elif prop["kind"] == "TARGET":
			target_props.append(prop["name"])

	target_props.sort()
	global_props.sort()

	out_lines: list[str] = []

	out_lines.append("Oranges defines the following global properties:")
	out_lines.append("")
	out_lines.extend(global_props)

	out_lines.append("")
	out_lines.append("Oranges defines the following target properties:")
	out_lines.append("")
	out_lines.extend(target_props)

	del global_props
	del target_props

	if out_file:
		if file_append:
			mode: Final[str] = "a"
		else:
			mode: Final[str] = "w"

		with open(out_file, mode, encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"The list of properties has been written to: {out_file}")
		return

	print("")

	for line in out_lines:
		print(line)

#

def print_help(property_name: str, out_file: str = None, file_append: bool = False) -> None:
	"""
	Prints help for the given property.
	"""

	def get_property_object():
		for prop in PROPERTIES_JSON["properties"]:
			if prop["name"] == property_name:
				return prop

		raise Exception(f"Property {property_name} not found!")

	property_info: Final = get_property_object()

	out_lines: list[str] = [property_name]

	out_lines.append("")
	out_lines.append(f"Kind: {property_info['kind']}")
	out_lines.append("")

	out_lines.append("Brief docs:")
	out_lines.append(property_info["briefDocs"])
	out_lines.append("")

	out_lines.append("Full docs:")
	out_lines.append(property_info["fullDocs"])

	del property_info

	if out_file:
		if file_append:
			mode: Final[str] = "a"
		else:
			mode: Final[str] = "w"

		with open(out_file, mode, encoding="utf-8") as f:
			f.write("\n".join(out_lines))

		print(f"Help for property {property_name} has been written to {out_file}")

		return

	print("")
	printing.section_heading(out_lines.pop(0))

	for line in out_lines:
		print(line)
