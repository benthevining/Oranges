#!/usr/bin/env python
# -*- coding: utf-8 -*-
# pylint: skip-file

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


def main():

	LEMONS_ROOT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

	CODEOWNERS = os.path.join(LEMONS_ROOT, '.github', 'CODEOWNERS')

	with open(CODEOWNERS, 'r') as f:
		file_lines = f.readlines()

	# remove empty lines
	file_lines = list(filter(None, file_lines))

	# sort remaining lines
	file_lines.sort()

	with open(CODEOWNERS, 'w') as f:
		f.truncate(0)
		f.write(''.join(file_lines))


if __name__ == '__main__':
	main()
