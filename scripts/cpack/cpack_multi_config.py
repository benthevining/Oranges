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

import os

#


def configure_build_tree(source_dir, binary_dir, config):
	pass


#


def compile_build_tree(binary_dir, config):
	pass


#


def configure_cpack(top_binary_dir):
	pass


#


def run_cpack(top_binary_dir):
	pass


#


def main(source_dir, configs):
	binary_dir = os.path.join(source_dir, 'Builds')

	for config in configs:
		config_binary_dir = os.path.join(binary_dir, config)

		configure_build_tree(source_dir, config_binary_dir, config)

		compile_build_tree(config_binary_dir, config)

	configure_cpack(binary_dir)

	run_cpack(binary_dir)


#

if __name__ == '__main__':
	main()
