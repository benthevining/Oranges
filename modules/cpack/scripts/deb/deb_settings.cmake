# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

# Follow Debian package naming conventions:
# https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html Build version, e.g.
# name_1.3.2~xenial_amd64 or name_1.3.2-1~xenial_amd64 when re-releasing. Note: the ~codename is not
# part of any standard and could be omitted.
include_guard (GLOBAL)

if(NOT CPACK_DEBIAN_PACKAGE_VERSION)
	if(${LSB_CODENAME} MATCHES "bionic")
		set (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}" CACHE INTERNAL "")
	else()
		set (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}~${LSB_CODENAME}" CACHE INTERNAL
																						   "")
	endif()
endif()

if(NOT CPACK_PACKAGE_FILE_NAME)
	find_program (DPKG dpkg)

	if(DPKG)
		execute_process (COMMAND "${DPKG}" --print-architecture OUTPUT_VARIABLE deb_arch
						 OUTPUT_STRIP_TRAILING_WHITESPACE)
		set (CPACK_PACKAGE_FILE_NAME
			 "${CPACK_PACKAGE_NAME}_${CPACK_DEBIAN_PACKAGE_VERSION}_${deb_arch}" CACHE INTERNAL "")
	else()
		message (
			AUTHOR_WARNING "Cannot locate dpkg, please manually specify CPACK_PACKAGE_FILE_NAME")
	endif()
endif()

if(NOT CPACK_DEBIAN_BUILD_DEPENDS)
	# attempt to parse project's config file
	set (depfile_path ${PROJECT_SOURCE_DIR}/${LOWER_PROJECT_NAME}_config.json)

	if(EXISTS ${depfile_path})

		include (LemonsInstallDeps)

		lemons_get_list_of_deps_to_install (OUTPUT deps_list FILE ${depfile_path})

		if(deps_list)
			set (CPACK_DEBIAN_BUILD_DEPENDS ${deps_list} CACHE INTERNAL "")
		endif()
	else()
		message (AUTHOR_WARNING "Depsfile not found, please specify CPACK_DEBIAN_BUILD_DEPENDS")
	endif()
endif()

# if (NOT CPACK_DEBIAN_PACKAGE_CONFLICTS) set (CPACK_DEBIAN_PACKAGE_CONFLICTS ${_package_conflicts})
# endif()

if(NOT DEFINED CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA)
	# script name must be 'postinst' to avoid lintian W: "unknown-control-file"
	set (_ldconfig_script "${CMAKE_CURRENT_LIST_DIR}/postinst")
	set (CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${_ldconfig_script};" CACHE INTERNAL "")
endif()

if(NOT CPACK_DEBIAN_PACKAGE_DEPENDS)
	set (CPACK_DEBIAN_PACKAGE_DEPENDS ${${UPPER_PROJECT_NAME}_PACKAGE_DEB_DEPENDS} CACHE INTERNAL
																						 "")
endif()

if(NOT CPACK_DEBIAN_PACKAGE_HOMEPAGE)
	set (CPACK_DEBIAN_PACKAGE_HOMEPAGE ${${UPPER_PROJECT_NAME}_URL} CACHE INTERNAL "")
endif()

# if (NOT CPACK_DEBIAN_PACKAGE_REPLACES) set (CPACK_DEBIAN_PACKAGE_REPLACES ${_package_replaces})
# endif()
