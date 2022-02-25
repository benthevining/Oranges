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
	set (CPACK_GENERATOR "NSIS" CACHE INTERNAL "")
	set (CPACK_NSIS_MODIFY_PATH ON CACHE INTERNAL "")
	return ()
endif()

if(APPLE)
	set (CPACK_GENERATOR "PackageMaker" CACHE INTERNAL "")
	set (CPACK_OSX_PACKAGE_VERSION "${${UPPER_PROJECT_NAME}_OSX_VERSION}")
	return ()
endif()

# Linux

if(LSB_DISTRIBUTOR_ID MATCHES "Ubuntu")
	set (CPACK_GENERATOR "DEB" CACHE INTERNAL "")
	return ()
endif()

if(LSB_DISTRIBUTOR_ID MATCHES "RedHatEnterpriseServer")
	set (CPACK_GENERATOR "RPM" CACHE INTERNAL "")
	return ()
endif()

find_program (DEB_EXE debuild)

if(DEB_EXE)
	set (CPACK_GENERATOR "DEB" CACHE INTERNAL "")
	return ()
endif()

find_program (RPM_EXE rpmbuild)

if(RPM_EXE)
	set (CPACK_GENERATOR "RPM" CACHE INTERNAL "")
else()
	set (CPACK_GENERATOR "TGZ" CACHE INTERNAL "")
endif()
