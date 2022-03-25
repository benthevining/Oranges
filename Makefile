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

override ORANGES_ROOT = $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

#

.PHONY: help
help:  ## Print this message
	@grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(ORANGES_ROOT)/Makefile | sort | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#

.PHONY: init
init:  ## Initializes the workspace and installs all dependencies
	@chmod +x $(ORANGES_ROOT)/scripts/alphabetize_codeowners.py
	@cd $(ORANGES_ROOT) && $(PRECOMMIT) install --install-hooks --overwrite && $(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg

#

.PHONY: config
config: ## configure CMake
	@cd $(ORANGES_ROOT) && $(CMAKE) --preset default

#

.PHONY: build
build: config ## runs CMake build
	@cd $(ORANGES_ROOT) && $(CMAKE) --build --preset default

.PHONY: conan
conan: ## Builds the Conan package
	@cd $(ORANGES_ROOT) && $(CONAN) create .

#

.PHONY: install
install: build ## runs CMake install
	@cd $(ORANGES_ROOT) && $(SUDO) $(CMAKE) --install $(BUILDS)

.PHONY: pack
pack: build ## Creates a CPack installer
	@cd $(ORANGES_ROOT) && $(CMAKE) --build $(BUILDS) --target package

#

.PHONY: test
test: build ## runs all tests
	@cd $(ORANGES_ROOT) && ctest --preset default

#

.PHONY: pc
pc:  ## Runs all pre-commit hooks over all files
	@cd $(ORANGES_ROOT) && $(GIT) add . && $(PRECOMMIT) run --all-files

#

.PHONY: deps_graph
deps_graph: config ## Generates a PNG image of the CMake dependency graph
	@cd $(ORANGES_ROOT) && $(CMAKE) --build --preset deps_graph

.PHONY: docs
docs: config ## Builds the documentation
	@cd $(ORANGES_ROOT) && $(CMAKE) --build --preset docs

#

.PHONY: uninstall
uninstall: ## Runs uninstall script
	@cd $(ORANGES_ROOT) && $(SUDO) $(CMAKE) -P $(BUILDS)/uninstall.cmake

.PHONY: clean
clean: ## Cleans the source tree
	@echo "Cleaning..."
	@cd $(ORANGES_ROOT) && $(RM) $(BUILDS) $(DOCS) $(DEPS_GRAPH).dot; $(PRECOMMIT) gc

.PHONY: wipe
wipe: ## Wipes the cache of downloaded dependencies
	@echo "Wiping cache..."
	@cd $(ORANGES_ROOT) && $(SUDO) $(CMAKE) -P $(BUILDS)/wipe_cache.cmake
