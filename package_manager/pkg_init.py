#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

#

import argparse

#


def install_system_packages():
	pass


#


def install_python_packages():
	pass


#


def install_git_repos(cache):
	pass
	# generate find modules
	# detect which ones are present in the source tree as subprojects (check their JSON files for project declarations with matching names)


#


def install_files():
	pass
	# check downloaded/present repos


#


def generate_project_shim(cache):
	pass


#


def pkg_init(cache):
	install_system_packages()
	install_python_packages()
	install_git_repos(cache)
	install_files()
	generate_project_shim(cache)


#

if __name__ == '__main__':

	parser = argparse.ArgumentParser()

	parser.add_argument('cache', help='Path to the dependency cache')

	args = parser.parse_args()

	# read JSON from standardized name in current directory

	pkg_init(args.cache)
