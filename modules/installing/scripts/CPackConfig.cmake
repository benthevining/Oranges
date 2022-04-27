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

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include ("@CMAKE_BINARY_DIR@/CPackConfig.cmake")

if ("${CPACK_GENERATOR}" STREQUAL "RPM")

	set (CPACK_PACKAGE_FILE_NAME
		 "@CPACK_PACKAGE_NAME@-@CPACK_PACKAGE_VERSION@.@CMAKE_SYSTEM_PROCESSOR@"
		 CACHE STRING "RPM package file name")

elseif ("${CPACK_GENERATOR}" STREQUAL "DEB")

	find_program (DPKG dpkg)

	mark_as_advanced (FORCE DPKG)

	if (DPKG)
		execute_process (
			COMMAND "${DPKG}" --print-architecture OUTPUT_VARIABLE deb_arch
			OUTPUT_STRIP_TRAILING_WHITESPACE)

		set (CPACK_PACKAGE_FILE_NAME
			 "@CPACK_PACKAGE_NAME@_@CPACK_DEBIAN_PACKAGE_VERSION@_${deb_arch}"
			 CACHE STRING "CPack package file name")

		set (CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${deb_arch}")

	else ()
		if (NOT CPACK_PACKAGE_FILE_NAME)
			message (
				AUTHOR_WARNING
					"Cannot locate dpkg, please manually specify CPACK_PACKAGE_FILE_NAME"
				)
		endif ()
	endif ()

endif ()
