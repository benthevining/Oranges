#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script updates a .cmake-format.json file's additional_commands field with command descriptions from another json file.
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

from argparse import ArgumentParser
import os
import json

#


def read_commands_from_json(input_file: str) -> dict[dict]:
	"""
	Parses the input JSON file and creates a dictionary of dictionaries, each entry representing a single CMake command specification.

	:param input_file: Absolute path of the input file to parse

	:returns: A dictionary of dictionaries, with each entry in the list representing one CMake command specification
	"""

	with open(input_file, "r", encoding="utf-8") as in_file:
		in_data = json.load(in_file)

	assert isinstance(in_data, dict)

	if "additional_commands" in in_data:
		parse_obj = in_data
	elif "parse" in in_data:
		parse_obj = in_data["parse"]
	else:
		return {}

	if not "additional_commands" in parse_obj:
		return {}

	return parse_obj["additional_commands"]


#


def update_cmakeformat_config(input_file: str, output_file: str) -> None:
	"""
	Updates the output .cmake-format.json file with the command descriptions found in the input file. Both input and output files must be valid JSON.

	:param input_file: Path to the input file to read. If this is a relative path, the file used will be ``$(pwd)/<input_file>``. The root object of this JSON file can contain the 'parse' key, or the 'additional_commands' key can be at the top level of the root object.
	:param output_file: Path to the config file to update. If this is a relative path, the file used will be ``$(pwd)/<output_file>``. Defaults to ``$(pwd)/.cmake-format.json``.
	"""

	if not output_file:
		output_file = os.path.join(os.getcwd(), ".cmake-format.json")

	if not os.path.isabs(input_file):
		input_file = os.path.join(os.getcwd(), input_file)

	if not os.path.isabs(output_file):
		output_file = os.path.join(os.getcwd(), output_file)

	input_commands = read_commands_from_json(input_file)

	with open(output_file, "r", encoding="utf-8") as output_read:
		orig_config = json.load(output_read)

	# first remove all commands in the input file from the output file
	if "parse" in orig_config:
		if "additional_commands" in orig_config["parse"]:
			for cmd_name in input_commands:
				if cmd_name in orig_config["parse"]["additional_commands"]:
					del orig_config["parse"]["additional_commands"][cmd_name]

	# now add them all back
	if not "parse" in orig_config:
		orig_config["parse"] = {}

	if not "additional_commands" in orig_config["parse"]:
		orig_config["parse"]["additional_commands"] = {}

	for cmd_name, cmd_spec in input_commands.items():
		orig_config["parse"]["additional_commands"][cmd_name] = cmd_spec

	with open(output_file, "w", encoding="utf-8") as output:
		json.dump(orig_config, output, sort_keys=True, indent=2)
		output.write("\n")


#


def _create_parser() -> ArgumentParser:
	"""
	Creates the argument parser for this script.

	:meta private:
	"""
	parser = ArgumentParser()

	parser.add_argument(
	    "--input",
	    "-i",
	    action="store",
	    dest="input_file",
	    required=True,
	    help=
	    "Path of the input file to read. If this is a relative path, the file used will be ``$(pwd)/<input_file>``."
	)

	parser.add_argument(
	    "--output",
	    "-o",
	    action="store",
	    dest="output_file",
	    required=False,
	    default=f"{os.path.join(os.getcwd(), '.cmake-format.json')}",
	    help=
	    "Path to the config file to update. If this is a relative path, the file used will be ``$(pwd)/<output_file>``. Defaults to ``$(pwd)/.cmake-format.json``."
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

		update_cmakeformat_config(input_file=args.input_file,
		                          output_file=args.output_file)
