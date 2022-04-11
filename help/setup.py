#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" setup.py
A simple setup script for packaging the help tool.
"""

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

from setuptools import find_packages, setup

# editorconfig-checker-disable

setup(name="oranges_help",
      version="2.14.1",
      author="Ben Vining",
      packages=find_packages(include=["oranges_help", "oranges_help.*"]),
      description="Command line help interface for the Oranges CMake library",
      url="www.github.com/benthevining/Oranges",
      classifiers=[
          "Development Status :: 3 - Alpha",
          "Intended Audience :: Developers",
          "Topic :: Software Development :: Reference",
          "License :: GPL3",
          "Programming Language :: Python :: 3",
          "Programming Language :: Python :: 3.7",
          "Programming Language :: Python :: 3.8",
          "Programming Language :: Python :: 3.9",
          "Programming Language :: Python :: 3.10",
          "Programming Language :: Python :: 3 :: Only",
      ],
      keywords="CMake, Oranges, reference, docs",
      python_requires=">=3.7, <4",
      entry_points={"console_scripts": ["oranges=oranges_help.main:main"]})

# editorconfig-checker-enable
