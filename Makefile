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

#

config: ## configure CMake
	@cd $(ORANGES_ROOT) && $(call cmake_default_configure)

build: config ## runs CMake build
	@cd $(ORANGES_ROOT) && $(call cmake_default_build)

install: build ## runs CMake install
	@cd $(ORANGES_ROOT) && $(call cmake_install)

pack: build ## Creates a CPack installer
	@cd $(ORANGES_ROOT) && $(call cpack_create_installer)

#

init:  ## Initializes the workspace and installs all dependencies
	@chmod +x $(ORANGES_ROOT)/scripts/alphabetize_codeowners.py
	@cd $(ORANGES_ROOT) && $(call precommit_init)


pc:  ## Runs all pre-commit hooks over all files
	@cd $(ORANGES_ROOT) && $(call run_precommit)

#

uninstall: ## Runs uninstall script [only works if project has been installed and was top-level project in configure]
	@$(call run_uninstall)

clean: ## Cleans the source tree
	@echo "Cleaning..."
	@cd $(ORANGES_ROOT) && $(call run_clean)

#

.PHONY: $(shell grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sed 's/:.*/\ /' | tr '\n' ' ')
