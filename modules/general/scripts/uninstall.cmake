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

set (manifest_file "@CMAKE_BINARY_DIR@/install_manifest.txt")

if(NOT EXISTS "${manifest_file}")
	message (WARNING "Install manifest file does not exist!")
	return ()
endif()

file (STRINGS "${manifest_file}" installed_files)

foreach(file ${installed_files})
	if(IS_SYMLINK "${file}" OR EXISTS "${file}")
		message (STATUS "Uninstalling ${file}")

		file (REMOVE "${file}")
	else()
		message (WARNING "File ${file} does not exist.")
	endif()
endforeach()
