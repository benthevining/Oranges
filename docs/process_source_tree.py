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


def extract_docblock(filepath: str) -> list[str]:
	"""
	Parses an RST documentation block from the given file.
	"""

	with open(filepath, "r", encoding="utf-8") as orig_module:
		module_lines: list[str] = orig_module.readlines()

	try:
		return module_lines[module_lines.index(
		    "#[=======================================================================[.rst:\n"
		):module_lines.index(
		    "#]=======================================================================]\n"
		)]
	except ValueError:
		return []


#


# editorconfig-checker-disable
def parse_doc_block_for_entities(
        filepath: str, entity_delimiter: str) -> dict[str, list[str]]:
	"""
	Parses the documentation block in the given file for entities documented by <entity_delimiter>
	"""

	# editorconfig-checker-enable

	module_lines: Final[list[str]] = extract_docblock(filepath)

	if not module_lines:
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


# editorconfig-checker-disable
def process_variables(orig_filepath: str, output_dir: str,
                      delimiter: str) -> None:
	"""
	Parses the given file for environment variable documentation, and generates a .rst file for each documented environment variable.
	"""
	# editorconfig-checker-enable

	var_docs: Final[dict[str, list[str]]] = parse_doc_block_for_entities(
	    orig_filepath, delimiter)

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


# editorconfig-checker-disable
def process_properties(orig_filepath: str, output_dir: str,
                       section_delimiter: str) -> None:
	"""
	Parses the given file for properties, and generates a .rst file for each documented property.
	"""
	# editorconfig-checker-enable

	doc_lines: list[str] = extract_docblock(orig_filepath)

	if not doc_lines:
		return

	try:
		doc_lines = doc_lines[doc_lines.index(f"{section_delimiter}\n") + 1:]
	except ValueError:
		return

	current_prop: str = None
	doc_sections: dict[str, list[str]] = {}

	for idx, line in enumerate(doc_lines):
		if line.startswith("``"):
			current_prop = line.removeprefix("``").removesuffix("``\n").strip()
			continue

		if idx + 1 < len(doc_lines) and doc_lines[idx + 1].startswith(
		    "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"):
			current_prop = None
			continue

		if current_prop:
			if current_prop in doc_sections:
				doc_sections[current_prop].append(line)
			else:
				doc_sections[current_prop] = [line]

	del doc_lines

	module_name: Final[str] = os.path.splitext(
	    os.path.basename(orig_filepath))[0]

	for prop, prop_doc in doc_sections.items():
		out_lines: list[str] = []

		out_lines.append(f"{prop}\n")
		out_lines.append("-------------------------\n")
		out_lines.append("\n")
		out_lines.append(f"Defined in module :module:`{module_name}`.\n")
		out_lines.append("\n")
		out_lines.extend(prop_doc)

		with open(os.path.join(output_dir, f"{prop}.rst"),
		          "w",
		          encoding="utf-8") as var_out:
			var_out.write("".join(out_lines))


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
		                                           "variable"),
		                  ".. cmake:variable::")
		process_variables(entry_path, os.path.join(output_base_dir, "envvar"),
		                  ".. cmake:envvar::")
		process_properties(entry_path, os.path.join(output_base_dir,
		                                            "prop_tgt"),
		                   "Target properties")
		process_properties(entry_path, os.path.join(output_base_dir,
		                                            "prop_gbl"),
		                   "Global properties")

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
