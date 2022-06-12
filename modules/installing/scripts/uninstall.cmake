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
    )# CMAKE_BINARY_DIR

# cmake-format: off
foreach (manifest_file IN LISTS manifest_files
			ITEMS install_manifest.txt
			@ORANGES_ADDITIONAL_INSTALL_MANIFEST_FILES@ # ORANGES_ADDITIONAL_INSTALL_MANIFEST_FILES expanded
	)
# cmake-format: on

    if (IS_ABSOLUTE "${manifest_file}")
        set (file_path "${manifest_file}")
    else ()
        set (file_path "@CMAKE_BINARY_DIR@/${manifest_file}")
    endif ()

    if (NOT EXISTS "${file_path}")
        message (WARNING "Install manifest file ${file_path} does not exist!")
        continue ()
    endif ()

    message (STATUS "Removing files listed in install manifest: ${file_path}")

    file (STRINGS "${file_path}" installed_files)

    foreach (file IN LISTS installed_files)
        if (IS_SYMLINK "${file}" OR EXISTS "${file}")
            list (APPEND files_to_uninstall "${file}")
        else ()
            message (WARNING "File ${file} does not exist.")
        endif ()
    endforeach ()

    # remove the manifest file
    file (REMOVE "${file_path}")
endforeach ()

if (NOT files_to_uninstall)
    message (WARNING "No files found to uninstall.")
    return ()
endif ()

list (REMOVE_DUPLICATES files_to_uninstall)

foreach (file IN LISTS files_to_uninstall)
    message (STATUS "Uninstalling ${file}")

    file (REMOVE "${file}")

    if (IS_SYMLINK "${file}" OR EXISTS "${file}")
        message (WARNING "Removing ${file} failed!")
    endif ()
endforeach ()
