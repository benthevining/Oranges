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
	 "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}.${CMAKE_SYSTEM_PROCESSOR}" CACHE INTERNAL "")

# set (CPACK_RPM_PACKAGE_CONFLICTS ${_package_conflicts})

set (CPACK_RPM_PACKAGE_GROUP "Development/Libraries" CACHE INTERNAL "")

# set (CPACK_RPM_PACKAGE_OBSOLETES ${_package_replaces})

set (CPACK_RPM_PACKAGE_RELEASE ${COMMON_PACKAGE_RELEASE} CACHE INTERNAL "")

set (CPACK_RPM_PACKAGE_URL ${${UPPER_PROJECT_NAME}_URL} CACHE INTERNAL "")
set (CPACK_RPM_PACKAGE_VERSION ${PROJECT_VERSION} CACHE INTERNAL "")

if(NOT CPACK_RPM_PACKAGE_REQUIRES)
	set (CPACK_RPM_PACKAGE_REQUIRES ${${UPPER_PROJECT_NAME}_PACKAGE_RPM_DEPENDS} CACHE INTERNAL "")
endif()

if(NOT CPACK_RPM_POST_INSTALL_SCRIPT_FILE)
	set (_ldconfig_script "${CMAKE_CURRENT_LIST_DIR}/rpmPostInstall.sh")
	set (CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${_ldconfig_script}" CACHE INTERNAL "")
endif()
