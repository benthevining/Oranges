SHELL := /bin/sh
.ONESHELL:
.SHELLFLAGS: -euo
.DEFAULT_GOAL: help
.NOTPARALLEL:
.POSIX:

#

# directory aliases
BUILDS ?= Builds
DOCS ?= doc
CACHE ?= Cache

#

override ORANGES_ROOT = $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

BUILD_DIR ?= $(ORANGES_ROOT)/$(BUILDS)

include $(ORANGES_ROOT)/util/util.make

#

.PHONY: help
help:  ## Print this message
	@$(call print_help,"$(ORANGES_ROOT)/Makefile")

#

.PHONY: init
init:  ## Initializes the workspace and installs all dependencies
	@cd $(ORANGES_ROOT) && \
		$(PRECOMMIT) install --install-hooks --overwrite && \
		$(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg
	@cd $(ORANGES_ROOT) && $(ASDF) install
	$(PYTHON) -m pip install -r $(ORANGES_ROOT)/requirements.txt

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

.PHONY: readme
readme: config ## Updates the readme with the list of modules found in the source tree
	@cd $(ORANGES_ROOT) && $(CMAKE) --build --preset readme

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
	@cd $(ORANGES_ROOT) && $(RM) $(BUILDS) $(DOCS); $(PRECOMMIT) gc

.PHONY: wipe
wipe: clean ## Wipes the cache of downloaded dependencies
	@echo "Wiping cache..."
	@if [ -d $(BUILD_DIR) ]; then \
		$(SUDO) $(CMAKE) -P $(BUILD_DIR)/wipe_cache.cmake; \
	fi
