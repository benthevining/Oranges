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

#

function(_oranges_install_system_packages)

	set (multiValueArgs SYSTEM_PACKAGES PIP_PACKAGES)

	cmake_parse_arguments (ORANGES_ARG "OPTIONAL" "" "${multiValueArgs}" ${ARGN})

	if(pkg_optional_flag)
		set (ORANGES_FORWARDED_ARGUMENTS OPTIONAL)
	else()
		oranges_forward_function_argument (PREFIX ORANGES_ARG KIND option ARG OPTIONAL)
	endif()

	oranges_forward_function_arguments (PREFIX ORANGES_ARG KIND multiVal ARGS ${multiValueArgs})

	oranges_install_packages (${ORANGES_FORWARDED_ARGUMENTS})

endfunction()

#

function(_oranges_install_git_repository)

	set (oneValueArgs NAME GIT_TAG GIT_REPOSITORY GITHUB_REPOSITORY GITLAB_REPOSITORY
					  BITBUCKET_REPOSITORY)

	cmake_parse_arguments (ORANGES_ARG "FULL" "${oneValueArgs}" "" ${ARGN})

	if(git_all_full)
		set (ORANGES_FORWARDED_ARGUMENTS FULL)
	else()
		oranges_forward_function_argument (PREFIX ORANGES_ARG KIND option ARG FULL)
	endif()

	oranges_forward_function_arguments (PREFIX ORANGES_ARG KIND oneVal ARGS ${oneValueArgs})

	oranges_fetch_repository (
		NAME
		"${ORANGES_ARG_NAME}"
		${ORANGES_FORWARDED_ARGUMENTS}
		${git_strategy_flag}
		${git_options_flag}
		DOWNLOAD_ONLY
		NEVER_LOCAL)

	configure_file ("${find_module_template}"
					"${GENERATED_FIND_MODULES}/Find${ORANGES_ARG_NAME}.cmake" @ONLY)

endfunction()

#

function(_oranges_install_file)

	set (oneValueArgs URL FILENAME OUTPUT_PATH USERNAME PASSWORD EXPECTED_HASH)

	cmake_parse_arguments (ORANGES_ARG "" "${oneValueArgs}" "" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG URL OUTPUT_PATH)

	oranges_forward_function_arguments (
		PREFIX
		ORANGES_ARG
		KIND
		oneVal
		ARGS
		URL
		USERNAME
		PASSWORD
		EXPECTED_HASH)

	if(ORANGES_ARG_FILENAME)
		set (file_name "${ORANGES_ARG_FILENAME}")
	else()
		cmake_path (GET OUTPUT_PATH FILENAME file_name)
	endif()

	oranges_download_file (${ORANGES_FORWARDED_ARGUMENTS} FILENAME "${file_name}" COPY_TO
						   "${OUTPUT_PATH}" ${timeout_flag})

endfunction()
