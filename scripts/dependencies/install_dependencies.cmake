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

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../..")

include ("${ORANGES_ROOT_DIR}/scripts/OrangesMacros.cmake")

include (OrangesInstallPackages)
include (OrangesFetchRepository)
include (OrangesDownloadFile)
include (LemonsCmakeDevTools)

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/helper_functions.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/scripts/parse_json_file.cmake")

if(NOT json_file_text)
	message (FATAL_ERROR "Error parsing JSON file ${JSON_FILE}!")
endif()

if(NOT PROJECT_NAME)
	message (FATAL_ERROR "JSON file must define project name!")
endif()

#

if(NOT CACHE)
	set (CACHE "${PROJECT_ROOT}/Cache")
endif()

if(NOT GENERATED_FIND_MODULES)
	set (GENERATED_FIND_MODULES "${CACHE}/generated_find_modules")
endif()

if(NOT SHIM_FILE)
	set (SHIM_FILE "${CACHE}/shim.cmake")
endif()

#

if(UPDATE_ALL_PACKAGES)
	oranges_update_all_packages ()
endif()

if(SYSTEM_PACKAGES_OPTIONAL)
	set (pkg_optional_flag TRUE CACHE INTERNAL "")
endif()

#

set (find_module_template "${CMAKE_CURRENT_LIST_DIR}/scripts/find_module_template.cmake"
	 CACHE INTERNAL "")

if(GIT_STRATEGY)
	set (git_strategy_flag "GIT_STRATEGY ${GIT_STRATEGY}" CACHE INTERNAL "")
endif()

if(GIT_OPTIONS)
	set (git_options_flag "GIT_OPTIONS ${GIT_OPTIONS}" CACHE INTERNAL "")
endif()

if(GIT_ALL_FULL)
	set (git_all_full "TRUE" CACHE INTERNAL "")
endif()

#

if(FILE_DOWNLOAD_TIMEOUT)
	set (timeout_flag "TIMEOUT ${FILE_DOWNLOAD_TIMEOUT}" CACHE INTERNAL "")
endif()

#

#[[ Install:
- files
- git repos

]]

include ("${CMAKE_CURRENT_LIST_DIR}/scripts/parse_system_packages.cmake")

if(optional_system_packages)
	_oranges_install_system_packages (SYSTEM_PACKAGES ${optional_system_packages} OPTIONAL)
endif()

if(optional_python_packages)
	_oranges_install_system_packages (PIP_PACKAGES ${optional_python_packages} OPTIONAL)
endif()

if(required_system_packages)
	_oranges_install_system_packages (SYSTEM_PACKAGES ${required_system_packages})
endif()

if(required_python_packages)
	_oranges_install_system_packages (PIP_PACKAGES ${required_python_packages})
endif()

#[[
- ignore_oranges (check for oranges in list of git repos)

_oranges_install_git_repository (NAME <name>
								 [GIT_TAG <tag>]
								 [GIT_REPOSITORY | GITHUB_REPOSITORY | GITLAB_REPOSITORY | BITBUCKET_REPOSITORY]
								 [FULL])
]]

#[[
# TO DO: add github repo and rel path options

_oranges_install_file (URL <url>
					   OUTPUT_PATH <localPath>
					   [FILENAME <filename>]
					   [USERNAME <userName>]
					   [PASSWORD <password>]
					   [EXPECTED_HASH <alg=expectedHash>])
]]

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/shim_template.cmake" "${SHIM_FILE}" @ONLY)

# generate a find module for THIS project!
set (ORANGES_ARG_NAME "${PROJECT_NAME}")
set (${PROJECT_NAME}_SOURCE_DIR "${PROJECT_ROOT}")

configure_file ("${find_module_template}" "${GENERATED_FIND_MODULES}/Find${PROJECT_NAME}.cmake"
				@ONLY)
