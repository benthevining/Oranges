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

#[=======================================================================[.rst:

OrangesIPOTarget
-------------------------

Provides a helper target for configuring IPO.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesIPO

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if(TARGET Oranges::OrangesIPO)
	return()
endif()

add_library (OrangesIPO INTERFACE)

include (CheckIPOSupported)

check_ipo_supported (RESULT ipo_supported OUTPUT ipo_output)

if(ipo_supported)
	set_target_properties (OrangesIPO PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)

	message (VERBOSE "Enabling IPO")
else()
	set_target_properties (OrangesIPO PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)
endif()

unset (ipo_output)
unset (ipo_supported)

install (TARGETS OrangesIPO EXPORT OrangesTargets)

add_library (Oranges::OrangesIPO ALIAS OrangesIPO)
