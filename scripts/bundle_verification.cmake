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

include (BundleUtilities)

# fixup_bundle (<app> <libs> <dirs>)

verify_bundle_symlinks ("@ORANGES_BU_BUNDLE@" symlinks_result symlinks_info)

if (NOT symlinks_result)
    message (
        FATAL_ERROR
            "Symlinks found in bundle @ORANGES_BU_BUNDLE@ pointing to outside bundle: ${symlinks_info}"
        )
endif ()

verify_bundle_prerequisites ("@ORANGES_BU_BUNDLE@" prereq_result prereq_info)

if (NOT prereq_result)
    message (FATAL_ERROR "Prerequisites missing for bundle @ORANGES_BU_BUNDLE@: ${prereq_info}")
endif ()

verify_app ("@ORANGES_BU_APP@")
