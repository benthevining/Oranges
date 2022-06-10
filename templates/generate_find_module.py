#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script generates a default CMake Find module for a package.

Even if a project provides CMake configuration files, it can be useful to have a find module for a project, which simply either adds a local version,
or fetches the sources from git at configure time. This allows you to add required packages to your build without separately installing each one
first.
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

from typing import Final, Tuple
from argparse import ArgumentParser
import os

# editorconfig-checker-disable
INPUT_FILE: Final[str] = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), "FindModuleTemplate.cmake")
# editorconfig-checker-enable

#


def replace_tokens(orig_string: str, tokens: list[Tuple[str, str]]) -> str:
	"""
	Replaces each occurange of a token in the input string with a replacement string.

	:param orig_string: The input string to modify
	:param tokens: A list of string pairs. The first element of each pair is the token to replace, and the second element is the string to replace the token with.

	:return: The modified string
	"""

	for token_pair in tokens:
		orig_string = orig_string.replace(token_pair[0], token_pair[1])

	return orig_string


#


# editorconfig-checker-disable
# pylint: disable=too-many-arguments
def generate(package_name: str,
             repo_url: str,
             git_repo: str,
             git_tag: str,
             description: str,
             output_dir: str,
             post_include_script: str = None,
             post_include_actions: str = None) -> None:
	"""
	Generates a find module for a CMake package.

	:param package_name: The name of the package (what you pass to `find_package()` to add your package)
	:param repo_url: The URL to your project's git repository
	:param git_repo: The URL to your project's git repository, including the trailing '.git'
	:param git_tag: The git tag or branch to fetch from your project's git repository
	:param description: A short description of your project
	:param output_dir: Directory to write the generated find module to. The actual file generated will be `${Directory}/Find${package_name}.cmake`
	:param post_include_script: Path to a script that will be executed after the package is found. Its contents will be pasted verbatim into the find module.
	:param post_include_actions: Verbatim CMake commands that will be executed after the package is found. These commands will be executed after any post_include_script (if one is specified).
	"""
	# editorconfig-checker-enable

	if not os.path.isabs(output_dir):
		output_dir = os.path.join(os.getcwd(), output_dir)

	output_file: Final[str] = os.path.join(output_dir,
	                                       f"Find{package_name}.cmake")

	del output_dir

	if os.path.isfile(output_file):
		os.remove(output_file)

	if post_include_script is not None:
		if not os.path.isabs(post_include_script):
			post_include_script = os.path.join(os.getcwd(),
			                                   post_include_script)
		with open(post_include_script, "r", encoding="utf-8") as f:
			post_include_script_text = f.read()
	else:
		post_include_script_text = ""

	if post_include_actions is None:
		post_include_actions = ""

	with open(INPUT_FILE, "r", encoding="utf-8") as f:
		file_text = f.read()

	file_text = replace_tokens(
	    file_text, [("<__package_name>", package_name),
	                ("<__upper_package_name>", package_name.upper()),
	                ("<__lower_package_name>", package_name.lower()),
	                ("<__package_repo_url>", repo_url),
	                ("<__package_git_repo>", git_repo),
	                ("<__package_git_tag>", git_tag),
	                ("<__package_description>", description),
	                ("<__post_include_script_text>", post_include_script_text),
	                ("<__post_include_actions>", post_include_actions)])

	with open(output_file, "w", encoding="utf-8") as f:
		f.write(file_text)


#


def __create_parser() -> ArgumentParser:
	"""
	Creates the argument parser for this script.

	:meta private:
	"""
	parser = ArgumentParser()

	parser.add_argument(
	    "--package",
	    "-p",
	    action="store",
	    dest="package_name",
	    required=True,
	    help=
	    "The name of the CMake package (what you pass to `find_package()` to add your package)"
	)

	parser.add_argument("--repo",
	                    "-r",
	                    action="store",
	                    dest="repo_url",
	                    required=True,
	                    help="The URL to your project's git repository")

	parser.add_argument(
	    "--git-url",
	    "-g",
	    action="store",
	    dest="git_repo",
	    required=False,
	    help=
	    "The URL to your project's git repository, including the trailing '.git'. Defaults to '$repo_url.git'"
	)

	parser.add_argument(
	    "--git-tag",
	    "-t",
	    action="store",
	    dest="git_tag",
	    required=False,
	    default="origin/main",
	    help="The git tag or branch to fetch from your project's git repository"
	)

	parser.add_argument(
	    "--description",
	    "-d",
	    action="store",
	    dest="description",
	    required=False,
	    help=
	    "A short description of your project. Defaults to 'The $package_name package'"
	)

	parser.add_argument(
	    "--output",
	    "-o",
	    action="store",
	    dest="output_dir",
	    required=False,
	    default=os.getcwd(),
	    help=
	    "Directory to write the generated find module to. The actual file generated will be '$Directory/Find$package_name.cmake'. Defaults to the current working directory."
	)

	parser.add_argument(
	    "--post-script",
	    action="store",
	    dest="post_script_path",
	    required=False,
	    default=None,
	    help=
	    "Path to a script that will be executed after the package is found. Its contents will be pasted verbatim into the find module."
	)

	parser.add_argument(
	    "--post-commands",
	    action="store",
	    dest="post_actions",
	    required=False,
	    default=None,
	    help=
	    "Verbatim CMake commands that will be executed after the package is found. These commands will be executed after any post-script (if one is specified)."
	)

	return parser


#

if __name__ == "__main__":
	from sys import argv

	my_parser = __create_parser()

	if len(argv) < 2:
		my_parser.print_help()
	else:
		args = my_parser.parse_args()

		if args.git_repo is None:
			args.git_repo = args.repo_url + ".git"

		if args.description is None:
			args.description = f"The {args.package_name} package"

		generate(package_name=args.package_name,
		         repo_url=args.repo_url,
		         git_repo=args.git_repo,
		         git_tag=args.git_tag,
		         description=args.description,
		         output_dir=args.output_dir,
		         post_include_script=args.post_script_path,
		         post_include_actions=args.post_actions)
