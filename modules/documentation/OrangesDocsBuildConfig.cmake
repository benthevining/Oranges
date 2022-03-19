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

An aggregate helper module that includes OrangesDoxygenConfig and, if the including project is the top level project, also includes OrangesGraphVizConfig.

Inclusion style: In each project

]]

# NO include_guard here - by design!

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

if(PROJECT_IS_TOP_LEVEL)
	include (OrangesGraphVizConfig)
endif()

include (OrangesDoxygenConfig)