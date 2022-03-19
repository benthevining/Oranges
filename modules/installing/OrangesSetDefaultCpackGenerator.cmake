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

When this modules is included, if CPACK_GENERATOR is not set, it will be set to a default value sensible for the current platform.

Inclusion style: Once globally

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

cmake_language (DEFER CALL message VERBOSE "Using CPack generator(s): ${CPACK_GENERATOR}")

if(CPACK_GENERATOR)
	return ()
endif()

if(MSVC OR WIN32)
	set (CPACK_GENERATOR "NSIS" CACHE STRING "CPack generator")
	return ()
endif()

if(APPLE)
	set (CPACK_GENERATOR "PackageMaker" CACHE STRING "CPack generator")
	return ()
endif()

if(NOT UNIX)
	set (CPACK_GENERATOR "TGZ" CACHE STRING "CPack generator")
	return ()
endif()

# Linux

include (LinuxLSBInfo)

if(LSB_DISTRIBUTOR_ID MATCHES "Ubuntu")
	set (CPACK_GENERATOR "DEB" CACHE STRING "CPack generator")
	return ()
endif()

if(LSB_DISTRIBUTOR_ID MATCHES "RedHatEnterpriseServer")
	set (CPACK_GENERATOR "RPM" CACHE STRING "CPack generator")
	return ()
endif()

find_program (ORANGES_DEB_EXE debuild)

mark_as_advanced (FORCE ORANGES_DEB_EXE)

if(ORANGES_DEB_EXE)
	set (CPACK_GENERATOR "DEB" CACHE STRING "CPack generator")
	return ()
endif()

find_program (ORANGES_RPM_EXE rpmbuild)

mark_as_advanced (FORCE ORANGES_RPM_EXE)

if(ORANGES_RPM_EXE)
	set (CPACK_GENERATOR "RPM" CACHE STRING "CPack generator")
	return ()
endif()

set (CPACK_GENERATOR "TGZ" CACHE STRING "CPack generator")
