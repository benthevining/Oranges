#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" paths.py
This module contains functions for working with paths of Oranges CMake modules.
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

from os import path, walk
from typing import Final

#

MODULES_DIR: Final[str] = path.join(path.dirname(path.dirname(path.dirname(path.realpath(__file__)))), "modules") # yapf: disable

FIND_MODULES_DIR: Final[str] = path.join(MODULES_DIR, "finders") # yapf: disable

#


def module_name_from_path(full_path: str) -> str:
	""" Returns the name of a module from its full filepath """

	return path.splitext(path.basename(full_path))[0]


def module_path_from_name(module_name: str) -> str:
	""" Returns the full path of a module from its name """

	path_list: list[str] = get_module_list()
	path_list.extend(get_finders_list())

	for full_path in path_list:
		if path.basename(full_path) == module_name:
			return full_path

	return None


#


def get_module_list() -> list[str]:
	""" Returns an array containing all the full paths to the Oranges CMake modules """

	child_dirs: list[str] = next(walk(MODULES_DIR))[1]

	child_dirs.remove("finders")
	child_dirs.remove("internal")

	child_dirs.append(path.join("juce", "plugins"))

	full_paths: list[str] = []

	for child_dir in child_dirs:
		child_dir_full_path: Final[str] = path.join(MODULES_DIR, child_dir)

		for child_file in next(walk(child_dir_full_path))[2]:
			if path.splitext(child_file)[1] == ".cmake":
				full_paths.append(path.join(child_dir_full_path, child_file))

	return list(set(full_paths))


#


def get_finders_list() -> list[str]:
	""" Returns an array containing all the full paths to the Oranges find modules """

	child_dirs: list[str] = next(walk(FIND_MODULES_DIR))[1]

	child_dirs.append(path.join("libs", "FFTW"))

	full_paths: list[str] = []

	for child_dir in child_dirs:
		child_dir_full_path: Final[str] = path.join(FIND_MODULES_DIR,
		                                            child_dir)

		for child_file in next(walk(child_dir_full_path))[2]:
			if child_file.startswith("Find") and path.splitext(
			    child_file)[1] == ".cmake":
				full_paths.append(path.join(child_dir_full_path, child_file))

	return list(set(full_paths))
