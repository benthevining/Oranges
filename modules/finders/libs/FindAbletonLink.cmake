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

FindAbletonLink
-------------------------

A find module for Ableton's Link library.

Output variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- AbletonLink_FOUND

Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Ableton::Link : the Ableton Link library

#]=======================================================================]

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (
	AbletonLink PROPERTIES URL "https://www.ableton.com/en/link/"
	DESCRIPTION "Library for communicating tempo changes between devices in a session")

#

oranges_file_scoped_message_context ("FindAbletonLink")

if(TARGET Ableton::Link)
	set (AbletonLink_FOUND TRUE)
	return ()
endif()

set (AbletonLink_FOUND FALSE)

#

find_package_try_pkgconfig (Ableton::Link link)

#

include (CPackComponent)

cpack_add_component (AbletonLink DISPLAY_NAME "Ableton Link" DESCRIPTION "Ableton Link library"
					 INSTALL_TYPES Developer)

#

find_path (ABLETONLINK_INCLUDES link.h)

find_library (ABLETONLINK_LIBRARIES NAMES link)

mark_as_advanced (FORCE ABLETONLINK_INCLUDES ABLETONLINK_LIBRARIES)

if(ABLETONLINK_INCLUDES AND ABLETONLINK_LIBRARIES)
	add_library (AbletonLink IMPORTED UNKNOWN)

	set_target_properties (AbletonLink PROPERTIES IMPORTED_LOCATION "${ABLETONLINK_LIBRARIES}")

	target_include_directories (AbletonLink PUBLIC "${ABLETONLINK_INCLUDES}")

	add_library (Ableton::Link ALIAS AbletonLink)

	set (AbletonLink_FOUND TRUE)

	install (IMPORTED_RUNTIME_ARTIFACTS AbletonLink COMPONENT AbletonLink)

	return ()
endif()

include (OrangesFetchRepository)

if(AbletonLink_FIND_QUIETLY)
	set (quiet_flag QUIET)
endif()

oranges_fetch_repository (
	NAME
	AbletonLink
	GITHUB_REPOSITORY
	Ableton/link
	GIT_TAG
	origin/master
	NEVER_LOCAL
	${quiet_flag})

unset (quiet_flag)

# TO DO...

set (AbletonLink_FOUND TRUE)
