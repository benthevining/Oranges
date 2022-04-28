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
CTEST ?= ctest
RM = $(CMAKE) -E rm -rf  # force this one to use CMake
PRECOMMIT ?= pre-commit
GIT ?= git
ASDF ?= asdf

# directory aliases
BUILDS ?= Builds
BUILD_DIR ?= $(ORANGES_ROOT)/$(BUILDS)
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

	# use GCC 10 on Linux
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
	@cd $(ORANGES_ROOT) && \
		$(PRECOMMIT) install --install-hooks --overwrite && \
		$(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg && \
		$(ASDF) install

#

$(BUILDS):
	@cd $(ORANGES_ROOT) && $(CMAKE) --preset default

.PHONY: config
config: $(BUILDS) ## configure CMake

#

.PHONY: build
build: config ## runs CMake build
	@cd $(ORANGES_ROOT) && $(CMAKE) --build --preset default

#

.PHONY: install
install: build ## runs CMake install
	$(SUDO) $(CMAKE) --install $(BUILD_DIR)

.PHONY: pack
pack: build ## Creates a CPack installer
	@$(CMAKE) --build $(BUILD_DIR) --target package

#

.PHONY: test
test: build ## runs all tests
	@cd $(ORANGES_ROOT) && $(CTEST) --preset default

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
	@if [ -d $(BUILD_DIR) ]; then \
		echo "Uninstalling..."; \
		$(SUDO) $(CMAKE) -P $(BUILD_DIR)/uninstall.cmake; \
	else \
		echo "Cannot uninstall, builds directory doesn't exist!"; \
	fi

.PHONY: clean
clean: ## Cleans the source tree
	@echo "Cleaning..."
	@cd $(ORANGES_ROOT) && $(RM) $(BUILDS) $(DOCS) $(DEPS_GRAPH).dot; $(PRECOMMIT) gc

.PHONY: wipe
wipe: clean ## Wipes the cache of downloaded dependencies
	@echo "Wiping cache..."
	@if [ -d $(BUILD_DIR) ]; then \
		$(SUDO) $(CMAKE) -P $(BUILD_DIR)/wipe_cache.cmake; \
	fi
