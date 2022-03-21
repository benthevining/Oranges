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

set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

include ("${ORANGES_ROOT_DIR}/scripts/OrangesMacros.cmake")

include (OrangesFetchRepository)

#

if(NOT CACHE)
	set (CACHE "${ORANGES_ROOT_DIR}/Cache")
endif()

set (FETCHCONTENT_BASE_DIR "${CACHE}" CACHE PATH "")

include (OrangesSetUpCache)

#

if(NOT NAME)
	set (NAME package)
endif()

if(GIT_TAG)
	set (tag_flag GIT_TAG "${GIT_TAG}")
endif()

if(FULL)
	set (full_flag FULL)
endif()

if(QUIET)
	set (quiet_flag QUIET)
endif()

if(NEVER_LOCAL)
	set (local_flag NEVER_LOCAL)
endif()

if(GIT_STRATEGY)
	set (git_strategy_flag GIT_STRATEGY "${GIT_STRATEGY}")
endif()

if(GIT_REPOSITORY)
	set (git_repo_flag GIT_REPOSITORY "${GIT_REPOSITORY}")
endif()

if(GITHUB_REPOSITORY)
	set (gh_repo_flag GITHUB_REPOSITORY "${GITHUB_REPOSITORY}")
endif()

if(GITLAB_REPOSITORY)
	set (gl_repo_flag GITLAB_REPOSITORY "${GITLAB_REPOSITORY}")
endif()

if(BITBUCKET_REPOSITORY)
	set (bb_repo_flag BITBUCKET_REPOSITORY "${BITBUCKET_REPOSITORY}")
endif()

oranges_fetch_repository (
	NAME
	"${NAME}"
	${git_repo_flag}
	${gh_repo_flag}
	${gl_repo_flag}
	${bb_repo_flag}
	${tag_flag}
	${full_flag}
	${quiet_flag}
	${local_flag}
	DOWNLOAD_ONLY
	${git_strategy_flag})
