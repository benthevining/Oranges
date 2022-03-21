SHELL := /bin/sh
.ONESHELL:
.SHELLFLAGS: -euo
.DEFAULT_GOAL: help
.NOTPARALLEL:
.POSIX:

#

override ORANGES_ROOT = $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

override THIS_MAKEFILE = $(ORANGES_ROOT)/Makefile

include $(ORANGES_ROOT)/scripts/util.make

#

help:  ## Print this message
	@$(call print_help)

.PHONY: $(shell grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sed 's/:.*/\ /' | tr '\n' ' ')

#

.PHONY: query_cmake_file_api
query_cmake_file_api:
	@$(call cmake_query_file_api,$(ORANGES_ROOT))

config: query_cmake_file_api ## configure CMake
	@cd $(ORANGES_ROOT) && $(CMAKE) --preset default

build: config ## runs CMake build
	@cd $(ORANGES_ROOT) && $(CMAKE) --build --preset default

test: build ## runs all tests
	@cd $(ORANGES_ROOT) && ctest --preset default

install: build ## runs CMake install
	@cd $(ORANGES_ROOT) && $(SUDO) $(CMAKE) --install $(BUILDS)

pack: build ## Creates a CPack installer
	@cd $(ORANGES_ROOT) && $(call cpack_create_installer)

#

deps_graph: config ## Generates a PNG image of the CMake dependency graph [requires graphviz's dot tool]
	@cd $(ORANGES_ROOT) && cmake --build --preset deps_graph

docs: config ## Builds the documentation
	@cd $(ORANGES_ROOT) && cmake --build --preset docs

#

init:  ## Initializes the workspace and installs all dependencies
	@chmod +x $(ORANGES_ROOT)/scripts/alphabetize_codeowners.py
	@cd $(ORANGES_ROOT) && $(call precommit_init)


pc:  ## Runs all pre-commit hooks over all files
	@cd $(ORANGES_ROOT) && $(call run_precommit)

#

uninstall: ## Runs uninstall script [only works if project has been installed]
	@$(call run_uninstall)

clean: ## Cleans the source tree
	@echo "Cleaning..."
	@cd $(ORANGES_ROOT) && $(call run_clean)

wipe: ## Wipes the cache of downloaded dependencies
	@echo "Wiping cache..."
	@cd $(ORANGES_ROOT) && $(call run_wipe_cache)
