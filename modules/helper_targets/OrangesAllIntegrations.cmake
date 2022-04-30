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

#[=======================================================================[.rst:

OrangesAllIntegrations
-------------------------

Searches for all static analysis integration programs and enables the ones that are available.

This module searches for the following packages:

- ccache
- clang-tidy
- cppcheck
- cpplint
- include-what-you-use

and enables build-time integrations for any of the tools that are found. No errors are emitted for unfound integration tools.

Note that this is a build-only target! You should always link to it using the following command:

.. code-block:: cmake

    target_link_libraries (YourTarget YOUR_SCOPE
        $<BUILD_INTERFACE:Oranges::OrangesAllIntegrations>)

If you get an error similar to: ::

    CMake Error: install(EXPORT "someExport" ...) includes target "yourTarget" which requires target "OrangesAllIntegrations" that is not in any export set.

then this is why. You're linking to OrangesAllIntegrations unconditionally (or with incorrect generator expressions).


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Oranges::OrangesAllIntegrations

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesAllIntegrations)
	return ()
endif ()

include (OrangesCmakeDevTools)

oranges_file_scoped_message_context ("OrangesAllIntegrations")

find_package (ccache MODULE QUIET)
find_package (clang-tidy MODULE QUIET)
find_package (cppcheck MODULE QUIET)
find_package (cpplint MODULE QUIET)
find_package (include-what-you-use MODULE QUIET)

add_library (OrangesAllIntegrations INTERFACE)

target_link_libraries (
	OrangesAllIntegrations
	INTERFACE
		$<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:ccache::ccache-interface>>
		$<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:Clang::clang-tidy-interface>>
		$<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:cppcheck::cppcheck-interface>>
		$<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:Google::cpplint-interface>>
		$<BUILD_INTERFACE:$<TARGET_NAME_IF_EXISTS:Google::include-what-you-use-interface>>
	)

add_library (Oranges::OrangesAllIntegrations ALIAS OrangesAllIntegrations)
