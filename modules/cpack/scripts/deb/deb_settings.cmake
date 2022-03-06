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

# Follow Debian package naming conventions:
# https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html Build version, e.g.
# name_1.3.2~xenial_amd64 or name_1.3.2-1~xenial_amd64 when re-releasing. Note: the ~codename is not
# part of any standard and could be omitted.
include_guard (GLOBAL)

if(${LSB_CODENAME} MATCHES "bionic")
	set (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}" CACHE STRING "Deb package version")
else()
	set (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}~${LSB_CODENAME}"
		 CACHE STRING "Deb package version")
endif()

if(ORANGES_MARK_ALL_CPACK_OPTIONS_ADVANCED)
	mark_as_advanced (FORCE CPACK_DEBIAN_PACKAGE_VERSION)
endif()

if(NOT CPACK_PACKAGE_FILE_NAME)
	find_program (DPKG dpkg)

	mark_as_advanced (FORCE DPKG)

	if(DPKG)
		execute_process (COMMAND "${DPKG}" --print-architecture OUTPUT_VARIABLE deb_arch
						 OUTPUT_STRIP_TRAILING_WHITESPACE)

		set (CPACK_PACKAGE_FILE_NAME
			 "${CPACK_PACKAGE_NAME}_${CPACK_DEBIAN_PACKAGE_VERSION}_${deb_arch}"
			 CACHE STRING "CPack package file name")

		if(ORANGES_MARK_ALL_CPACK_OPTIONS_ADVANCED)
			mark_as_advanced (FORCE CPACK_PACKAGE_FILE_NAME)
		endif()
	else()
		message (
			AUTHOR_WARNING "Cannot locate dpkg, please manually specify CPACK_PACKAGE_FILE_NAME")
	endif()
endif()

# CPACK_DEBIAN_BUILD_DEPENDS CPACK_DEBIAN_PACKAGE_CONFLICTS CPACK_DEBIAN_PACKAGE_REPLACES

set (CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_LIST_DIR}/postinst;"
	 CACHE PATH "Deb post-install script")

set (CPACK_DEBIAN_PACKAGE_DEPENDS "${${UPPER_PROJECT_NAME}_PACKAGE_DEB_DEPENDS}"
	 CACHE STRING "Deb package dependencies")

set (CPACK_DEBIAN_PACKAGE_HOMEPAGE "${${UPPER_PROJECT_NAME}_URL}" CACHE STRING
																		"Deb package homepage URL")

if(ORANGES_MARK_ALL_CPACK_OPTIONS_ADVANCED)
	mark_as_advanced (FORCE CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA CPACK_DEBIAN_PACKAGE_DEPENDS
					  CPACK_DEBIAN_PACKAGE_HOMEPAGE)
endif()
