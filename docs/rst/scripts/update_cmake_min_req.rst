update_cmake_min_req
-------------------------------

The script ``update_cmake_min_req.py`` allows you to scan a CMake project tree and update all instances of ``cmake_minimum_required()`` to a new specified minimum version of CMake.

Command-line usage
^^^^^^^^^^^^^^^^^^^^^^

.. argparse::
	:module: update_cmake_min_req
	:func: __create_parser
	:prog: update_cmake_min_req

Module functions
^^^^^^^^^^^^^^^^^^^^^^

.. automodule:: update_cmake_min_req
	:members:
	:synopsis: Update cmake_minimum_required commands to the latest version of CMake
