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

#[[

Inputs:
- json_file_text
- name of set(s)

Outputs:
- optional_system_packages
- optional_python_packages
- required_system_packages
- required_python_packages

]]

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

#[[

- identify the set to use (either specified on cmd line or find the one marked as the project default) - or option for all
- for each set, resolve all includes

]]
