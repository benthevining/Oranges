update_cmakeformat_config
-------------------------------

The `CMakeFormat <https://github.com/cheshirekow/cmake_format>`_ tool provides powerful formatting and linting for CMake files, and it allows you to specify the semantics of any custom CMake functions in your configuration file (.cmake-format.json). This script provides a way to update all the command specifications in one file with those present in another file.

Oranges provides a JSON file containing command specifications for all commands provided by Oranges modules; this file is located at ``util/OrangesCMakeCommands.json``. You can update your CMakeFormat configuration file by running this command from the root of the Oranges repository:

.. code-block:: shell

	python3 scripts/update_cmakeformat_config.py --input=util/OrangesCMakeCommands.json --output=<pathToYourConfigFile>

Command-line usage
^^^^^^^^^^^^^^^^^^^^^^

.. argparse::
	:module: update_cmakeformat_config
	:func: _create_parser
	:prog: update_cmakeformat_config

Module functions
^^^^^^^^^^^^^^^^^^^^^^

.. automodule:: update_cmakeformat_config
	:members:
	:synopsis: Update a CMakeFormat configuration file with external command specifications
