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

include_guard (GLOBAL)

if(MSVC OR WIN32)
	set (CPACK_GENERATOR "NSIS" CACHE STRING "CPack generator")
	set (CPACK_NSIS_MODIFY_PATH ON)
	return ()
endif()

if(APPLE)
	set (CPACK_GENERATOR "PackageMaker" CACHE STRING "CPack generator")
	set (CPACK_OSX_PACKAGE_VERSION "${${UPPER_PROJECT_NAME}_OSX_VERSION}")
	return ()
endif()

# Linux

if(LSB_DISTRIBUTOR_ID MATCHES "Ubuntu")
	set (CPACK_GENERATOR "DEB" CACHE STRING "CPack generator")
	return ()
endif()

if(LSB_DISTRIBUTOR_ID MATCHES "RedHatEnterpriseServer")
	set (CPACK_GENERATOR "RPM" CACHE STRING "CPack generator")
	return ()
endif()

find_program (DEB_EXE debuild)

mark_as_advanced (FORCE DEB_EXE)

if(DEB_EXE)
	set (CPACK_GENERATOR "DEB" CACHE STRING "CPack generator")
	return ()
endif()

find_program (RPM_EXE rpmbuild)

mark_as_advanced (FORCE RPM_EXE)

if(RPM_EXE)
	set (CPACK_GENERATOR "RPM" CACHE STRING "CPack generator")
	return ()
endif()

set (CPACK_GENERATOR "TGZ" CACHE STRING "CPack generator")
