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

set (files_to_uninstall "")

file (GLOB manifest_files RELATIVE "@CMAKE_BINARY_DIR@" @CMAKE_BINARY_DIR@/install_manifest_*.txt
	  )# @CMAKE_BINARY_DIR@

foreach(manifest_file install_manifest.txt ${manifest_files})
	set (file_path "@CMAKE_BINARY_DIR@/${manifest_file}")

	if(NOT EXISTS "${file_path}")
		message (WARNING "Install manifest file ${file_path} does not exist!")
	else()
		message (STATUS "Removing files listed in install manifest: ${file_path}")

		file (STRINGS "${file_path}" installed_files)

		foreach(file ${installed_files})
			if(IS_SYMLINK "${file}" OR EXISTS "${file}")
				list (APPEND files_to_uninstall "${file}")
			else()
				message (WARNING "File ${file} does not exist.")
			endif()
		endforeach()
	endif()
endforeach()

list (REMOVE_DUPLICATES files_to_uninstall)

foreach(file ${files_to_uninstall})
	message (STATUS "Uninstalling ${file}")

	file (REMOVE "${file}")

	if(IS_SYMLINK "${file}" OR EXISTS "${file}")
		message (WARNING "Removing ${file} failed!")
	endif()
endforeach()
