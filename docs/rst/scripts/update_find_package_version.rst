update_find_package_version
-------------------------------

The script ``update_find_package_version.py`` allows you to scan a CMake project tree and update all instances of ``find_package()`` and ``find_dependency()`` for a certain package to a new specified version.

Command-line usage
^^^^^^^^^^^^^^^^^^^^^^

.. argparse::
	:module: update_find_package_version
	:func: _create_parser
	:prog: update_find_package_version

Module functions
^^^^^^^^^^^^^^^^^^^^^^

.. automodule:: update_find_package_version
	:members:
	:synopsis: Update find_package commands to the latest version of a package
