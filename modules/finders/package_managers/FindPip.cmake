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

#[[

Find module for the pip Python package manager. This module finds pip3.

Targets:
- Python3::Pip : the pip executable.

Output variables:
- Pip_FOUND

## Functions:

### pip_upgrade_all
```
pip_upgrade_all()
```

Upgrades all installed packages.


### pip_install_packages
```
pip_install_packages (PACKAGES <packageNames>
					  [UPDATE_FIRST] [OPTIONAL])
```

Installs the list of packages using pip.
If the `UPDATE_FIRST` first option is present, all installed packages will be updated before installing new packages.
If the `OPTIONAL` option is present, it is not an error for a package to fail to install.

]]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (OrangesFindPackageHelpers)

set_package_properties (Pip PROPERTIES URL "https://pypi.org/project/pip/"
						DESCRIPTION "Python package manager")

set (Pip_FOUND FALSE)

find_package (Python3 COMPONENTS Interpreter)

if(TARGET Python3::Interpreter)

	find_package_execute_process (COMMAND Python3::Interpreter -m ensurepip --upgrade)

	find_package_execute_process (
		COMMAND
		Python3::Interpreter
		-m
		pip3
		install
		--upgrade
		pip3)

	find_program (PIP3 pip3)

	mark_as_advanced (FORCE PIP3)
else()
	find_package_warning_or_error ("Python interpreter cannot be found!")
endif()

if(PIP3)
	set (Pip_FOUND TRUE)

	add_executable (Pip IMPORTED GLOBAL)

	set_target_properties (Pip PROPERTIES IMPORTED_LOCATION "${PIP3}")

	add_executable (Python3::Pip ALIAS Pip)
else()
	find_package_warning_or_error ("Pip cannot be found!")
endif()

#

function(pip_upgrade_all)

	if(NOT TARGET Python3::Pip)
		message (FATAL_ERROR "Pip3 cannot be found!")
	endif()

	execute_process (COMMAND Python3::Pip list --outdated --format=freeze COMMAND grep -v "'^\\-e'"
					 COMMAND cut -d = -f 1 COMMAND xargs -n1 pip install -U COMMAND_ECHO STDOUT)

endfunction()

#

function(pip_install_packages)

	if(NOT TARGET Python3::Pip)
		message (FATAL_ERROR "Pip3 cannot be found!")
	endif()

	set (options UPDATE_FIRST OPTIONAL)

	cmake_parse_arguments (ORANGES_ARG "${options}" "" "PACKAGES" ${ARGN})

	lemons_require_function_arguments (ORANGES_ARG PACKAGES)

	if(ORANGES_ARG_UPDATE_FIRST)
		pip_upgrade_all ()
	endif()

	if(NOT ORANGES_ARG_OPTIONAL)
		set (error_flag COMMAND_ERROR_IS_FATAL ANY)
	endif()

	execute_process (COMMAND Python3::Pip install --upgrade ${ORANGES_ARG_PACKAGES} COMMAND_ECHO
							 STDOUT ${error_flag})

endfunction()
