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

set (CPACK_PACKAGE_FILE_NAME
	 "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}.${CMAKE_SYSTEM_PROCESSOR}"
	 CACHE STRING "RPM package file name")

set (CPACK_RPM_PACKAGE_GROUP "Development/Libraries" CACHE STRING "RPM package group")

if(MARK_ALL_CPACK_OPTIONS_ADVANCED)
	mark_as_advanced (FORCE CPACK_PACKAGE_FILE_NAME CPACK_RPM_PACKAGE_GROUP)
endif()

# CPACK_RPM_PACKAGE_CONFLICTS CPACK_RPM_PACKAGE_OBSOLETES

if(COMMON_PACKAGE_RELEASE)
	set (CPACK_RPM_PACKAGE_RELEASE "${COMMON_PACKAGE_RELEASE}" CACHE STRING "")

	if(MARK_ALL_CPACK_OPTIONS_ADVANCED)
		mark_as_advanced (FORCE CPACK_RPM_PACKAGE_RELEASE)
	endif()
endif()

set (CPACK_RPM_PACKAGE_URL "${${UPPER_PROJECT_NAME}_URL}" CACHE STRING "RPM package homepage URL")

set (CPACK_RPM_PACKAGE_VERSION "${PROJECT_VERSION}" CACHE STRING "RPM package version")

set (CPACK_RPM_PACKAGE_REQUIRES "${${UPPER_PROJECT_NAME}_PACKAGE_RPM_DEPENDS}"
	 CACHE STRING "RPM package dependencies")

set (CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_LIST_DIR}/rpmPostInstall.sh"
	 CACHE PATH "RPM post-install script")

if(MARK_ALL_CPACK_OPTIONS_ADVANCED)
	mark_as_advanced (FORCE CPACK_RPM_PACKAGE_URL CPACK_RPM_PACKAGE_VERSION
					  CPACK_RPM_PACKAGE_REQUIRES CPACK_RPM_POST_INSTALL_SCRIPT_FILE)
endif()
