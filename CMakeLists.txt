include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

project (
	Oranges
	VERSION 0.1.0
	DESCRIPTION "CMake modules, scripts, and utilities"
	HOMEPAGE_URL "www.github.com/benthevining/Oranges"
	LANGUAGES NONE)

set (CPM_Oranges_SOURCE "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

include ("${CMAKE_CURRENT_LIST_DIR}/OrangesConfig.cmake")

# install files

include (GNUInstallDirs)
include (CMakePackageConfigHelpers)

set (installDest ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

foreach(module_path ${lemonsModulePaths})
	install (DIRECTORY ${module_path} DESTINATION ${installDest} COMPONENT ${PROJECT_NAME})
endforeach()

write_basic_package_version_file ("${PROJECT_NAME}ConfigVersion.cmake" VERSION ${PROJECT_VERSION}
								  COMPATIBILITY SameMajorVersion)

install (FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
			   "${PROJECT_NAME}Config.cmake" DESTINATION ${installDest} COMPONENT ${PROJECT_NAME})
