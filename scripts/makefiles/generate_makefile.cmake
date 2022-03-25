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

#

function(require_script_argument inputVar)
	if(NOT inputVar)
		message (FATAL_ERROR "Required input variable ${inputVar} is not defined!")
	endif()
endfunction()

require_script_argument (PROJECT_NAME)

if(OUT_FILE)
	cmake_path (IS_ABSOLUTE OUT_FILE is_abs_path)

	if(NOT is_abs_path)
		set (OUT_FILE "${CMAKE_CURRENT_LIST_DIR}/${OUT_FILE}")
	endif()
else()
	set (OUT_FILE "${CMAKE_CURRENT_LIST_DIR}/Makefile")
endif()

#

#[[
OPTIONS TO ADD:
- turn precommit, conan, docs tasks on/off
- CMake use presets (specify names) or default cmd line (specify target(s))
- custom init step(s)
]]

#

set (
	makefile_text
	[[
SHELL := /bin/sh
.ONESHELL:
.SHELLFLAGS: -euo
.DEFAULT_GOAL: help
.NOTPARALLEL:
.POSIX:

#

CONFIG ?= Release

export CMAKE_BUILD_TYPE ?= $(CONFIG)
export CMAKE_CONFIG_TYPE ?= $(CONFIG)
export VERBOSE ?= 1

# program aliases
CMAKE ?= cmake
RM = $(CMAKE) -E rm -rf
PRECOMMIT ?= pre-commit
GIT ?= git
CONAN ?= conan

# directory aliases
BUILDS ?= Builds
DOCS ?= doc
CACHE ?= Cache
DEPS_GRAPH ?= deps_graph

# set default CMake generator & build parallel level
ifeq ($(OS),Windows_NT)
	export CMAKE_GENERATOR ?= Visual Studio 17 2022
	export CMAKE_BUILD_PARALLEL_LEVEL ?= $(NUMBER_OF_PROCESSORS)
else ifeq ($(shell uname -s),Darwin)
	export CMAKE_GENERATOR ?= Xcode
	export CMAKE_BUILD_PARALLEL_LEVEL ?= $(shell sysctl hw.ncpu | awk '{print $$2}')
	SUDO ?= sudo
else # Linux
	export CMAKE_GENERATOR ?= Ninja
	export CMAKE_BUILD_PARALLEL_LEVEL ?= $(shell grep -c ^processor /proc/cpuinfo)
	SUDO ?= sudo

	# use GCC 10+ on Linux
	export CC=gcc-10
	export CXX=g++-10
endif

#

override @PROJECT_NAME@_ROOT = $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

#

.PHONY: help
help:  ## Print this message
	@grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(@PROJECT_NAME@_ROOT)/Makefile | sort | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#

.PHONY: init
init:  ## Initializes the workspace and installs all dependencies
	@chmod +x $(@PROJECT_NAME@_ROOT)/scripts/alphabetize_codeowners.py
	@cd $(@PROJECT_NAME@_ROOT) && $(PRECOMMIT) install --install-hooks --overwrite && $(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg

#

.PHONY: config
config: ## configure CMake
	@cd $(@PROJECT_NAME@_ROOT) && $(CMAKE) --preset default

#

.PHONY: build
build: config ## runs CMake build
	@cd $(@PROJECT_NAME@_ROOT) && $(CMAKE) --build --preset default

.PHONY: conan
conan: ## Builds the Conan package
	@cd $(@PROJECT_NAME@_ROOT) && $(CONAN) create .

#

.PHONY: install
install: build ## runs CMake install
	@cd $(@PROJECT_NAME@_ROOT) && $(SUDO) $(CMAKE) --install $(BUILDS)

.PHONY: pack
pack: build ## Creates a CPack installer
	@cd $(@PROJECT_NAME@_ROOT) && $(CMAKE) --build $(BUILDS) --target package

#

.PHONY: test
test: build ## runs all tests
	@cd $(@PROJECT_NAME@_ROOT) && ctest --preset default

#

.PHONY: pc
pc:  ## Runs all pre-commit hooks over all files
	@cd $(@PROJECT_NAME@_ROOT) && $(GIT) add . && $(PRECOMMIT) run --all-files

#

.PHONY: deps_graph
deps_graph: config ## Generates a PNG image of the CMake dependency graph
	@cd $(@PROJECT_NAME@_ROOT) && $(CMAKE) --build --preset deps_graph

.PHONY: docs
docs: config ## Builds the documentation
	@cd $(@PROJECT_NAME@_ROOT) && $(CMAKE) --build --preset docs

#

.PHONY: uninstall
uninstall: ## Runs uninstall script
	@cd $(@PROJECT_NAME@_ROOT) && $(SUDO) $(CMAKE) -P $(BUILDS)/uninstall.cmake

.PHONY: clean
clean: ## Cleans the source tree
	@echo "Cleaning..."
	@cd $(@PROJECT_NAME@_ROOT) && $(RM) $(BUILDS) $(DOCS) $(DEPS_GRAPH).dot; $(PRECOMMIT) gc

.PHONY: wipe
wipe: ## Wipes the cache of downloaded dependencies
	@echo "Wiping cache..."
	@cd $(@PROJECT_NAME@_ROOT) && $(SUDO) $(CMAKE) -P $(BUILDS)/wipe_cache.cmake
	]])

string (CONFIGURE "${makefile_text}" makefile_text @ONLY)

file (WRITE "${OUT_FILE}" "${makefile_text}")
