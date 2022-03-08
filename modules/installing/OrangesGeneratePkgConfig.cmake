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

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (GNUInstallDirs)

set (pc_file_dir "${PROJECT_BINARY_DIR}/pkgconfig")

set (pc_file_configured "${pc_file_dir}/${PROJECT_NAME}.pc.in")

configure_file ("${CMAKE_CURRENT_LIST_DIR}/scripts/config.pc" "${pc_file_configured}" @ONLY)

set (pc_file_output "${pc_file_dir}/${PROJECT_NAME}-$<CONFIG>.pc")

if(NOT TARGET "${PROJECT_NAME}")

endif()

file (GENERATE OUTPUT "${pc_file_output}" INPUT "${pc_file_configured}" TARGET "${PROJECT_NAME}"
																		NEWLINE_STYLE UNIX)

install (FILES "${pc_file_output}" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig")
