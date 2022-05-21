#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utility functions for parsing the source tree to create Sphinx's build tree.
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
import os

#


# editorconfig-checker-disable
def parse_doc_block_for_entities(
        filepath: str, entity_delimiter: str) -> dict[str, list[str]]:
	"""
	Parses the documentation block in the given file for entities documented by <entity_delimiter>
	"""

	# editorconfig-checker-enable

	with open(filepath, "r", encoding="utf-8") as orig_module:
		module_lines: list[str] = orig_module.readlines()

	try:
		module_lines = module_lines[module_lines.index(
		    "#[=======================================================================[.rst:\n"
		):module_lines.index(
		    "#]=======================================================================]\n"
		)]
	except ValueError:
		return {}

	current_name: str = None
	doc_sections: dict[str, list[str]] = {}

	for idx, line in enumerate(module_lines):
		if line.startswith(entity_delimiter):
			current_name = line[len(entity_delimiter):].strip()
			continue

		if idx + 1 < len(module_lines) and module_lines[idx + 1].startswith(
		    "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"):
			current_name = None
			continue

		if current_name:
			if current_name in doc_sections:
				doc_sections[current_name].append(line)
			else:
				doc_sections[current_name] = [line]

	return doc_sections


#


def process_commands(orig_filepath: str, output_dir: str) -> None:
	"""
	Parses the given file for command documentation, and generates a .rst file for each documented command.
	"""

	command_docs: Final[dict[str, list[str]]] = parse_doc_block_for_entities(
	    orig_filepath, ".. command::")

	if not command_docs:
		return

	module_name: Final[str] = os.path.splitext(
	    os.path.basename(orig_filepath))[0]

	for command, doc_lines in command_docs.items():
		cmd_lines: list[str] = []

		cmd_lines.append(f"{command}\n")
		cmd_lines.append("-------------------------------\n")
		cmd_lines.append("\n")
		cmd_lines.append(".. code-block:: cmake\n")
		cmd_lines.append("\n")
		cmd_lines.append(f"    include ({module_name})\n")
		cmd_lines.append("\n")
		cmd_lines.append(
		    f"View the full docs for :module:`this module <{module_name}>`.\n")
		cmd_lines.append("\n")
		cmd_lines.extend(doc_lines)

		with open(os.path.join(output_dir, f"{command}.rst"),
		          "w",
		          encoding="utf-8") as cmd_out:
			cmd_out.write("".join(cmd_lines))


#


def process_variables(orig_filepath: str, output_dir: str) -> None:
	"""
	Parses the given file for variable documentation, and generates a .rst file for each documented variable.
	"""

	var_docs: Final[dict[str, list[str]]] = parse_doc_block_for_entities(
	    orig_filepath, ".. cmake:variable::")

	if not var_docs:
		return

	module_name: Final[str] = os.path.splitext(
	    os.path.basename(orig_filepath))[0]

	for variable, doc_lines in var_docs.items():
		var_lines: list[str] = []

		var_lines.append(f"{variable}\n")
		var_lines.append("-------------------------------\n")
		var_lines.append("\n")
		var_lines.append(f"Defined in module :module:`{module_name}`.\n")
		var_lines.append("\n")
		var_lines.extend(doc_lines)

		with open(os.path.join(output_dir, f"{variable}.rst"),
		          "w",
		          encoding="utf-8") as var_out:
			var_out.write("".join(var_lines))


#


def process_env_variables(orig_filepath: str, output_dir: str) -> None:
	"""
	Parses the given file for environment variable documentation, and generates a .rst file for each documented environment variable.
	"""

	var_docs: Final[dict[str, list[str]]] = parse_doc_block_for_entities(
	    orig_filepath, ".. cmake:envvar::")

	if not var_docs:
		return

	module_name: Final[str] = os.path.splitext(
	    os.path.basename(orig_filepath))[0]

	for variable, doc_lines in var_docs.items():
		var_lines: list[str] = []

		var_lines.append(f"{variable}\n")
		var_lines.append("-------------------------------\n")
		var_lines.append("\n")
		var_lines.append(f"Defined in module :module:`{module_name}`.\n")
		var_lines.append("\n")
		var_lines.extend(doc_lines)

		with open(os.path.join(output_dir, f"{variable}.rst"),
		          "w",
		          encoding="utf-8") as var_out:
			var_out.write("".join(var_lines))


#


def process_directory(dir_path: str, output_base_dir: str) -> None:
	"""
	Processes all CMake modules in a directory, recursively.
	"""

	for entry in os.listdir(dir_path):

		if entry == "scripts":
			continue

		entry_path: Final[str] = os.path.join(dir_path, entry)

		if os.path.isdir(entry_path):
			process_directory(entry_path, output_base_dir)
			continue

		if not os.path.isfile(entry_path):
			continue

		if not entry.endswith(".cmake"):
			continue

		process_commands(entry_path, os.path.join(output_base_dir, "command"))
		process_variables(entry_path, os.path.join(output_base_dir,
		                                           "variable"))
		process_env_variables(entry_path,
		                      os.path.join(output_base_dir, "envvar"))

		if os.path.basename(entry_path).startswith("Find"):
			base_dir: Final[str] = os.path.join(output_base_dir,
			                                    "find_modules")
		else:
			base_dir: Final[str] = os.path.join(output_base_dir, "module")

		output_file: Final[str] = os.path.join(
		    base_dir, f"{entry.removesuffix('.cmake')}.rst")

		output_path: Final[str] = os.path.relpath(entry_path, start=base_dir)

		with open(output_file, "w", encoding="utf-8") as rst_out:
			rst_out.write(f".. cmake-module:: {output_path}")
