generate_find_module
-------------------------------

The script ``generate_find_module.py`` automatically generates a find module for a CMake package.

The generated find module will allow the developer to set a path to a local copy of the package, and includes some basic version checking logic for local copies of the code.

If a local path is not set, CMake's FetchContent module will be used to fetch the package's sources using git at configure time.

Even if a package provides CMake configuration files, it can be useful to have such a find module for it, because this allows you to add required packages to your build specification, while still ensuring that your build will work out of the box for consumers of your project, without them separately installing each dependency first.

Command-line usage
^^^^^^^^^^^^^^^^^^^^^^

.. argparse::
	:module: generate_find_module
	:func: __create_parser
	:prog: generate_find_module

Module functions
^^^^^^^^^^^^^^^^^^^^^^

.. automodule:: generate_find_module
	:members:
	:synopsis: Generate a find module for a CMake package
