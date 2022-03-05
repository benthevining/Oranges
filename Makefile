SHELL = /bin/sh
.ONESHELL:
.SHELLFLAGS: -euo
.DEFAULT_GOAL: help
.NOTPARALLEL:
.POSIX:

#

CMAKE = cmake
CPACK = cpack
PRECOMMIT = pre-commit
RM = rm -rf

override ORANGES_ROOT := $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

override THIS_MAKEFILE := $(ORANGES_ROOT)/Makefile

ifeq ($(OS),Windows_NT)
	CMAKE_GENERATOR = Visual Studio 17 2022
else ifeq ($(shell uname -s),Darwin)
	CMAKE_GENERATOR = Xcode
else
	CMAKE_GENERATOR = Ninja
	export CC=gcc-10
	export CXX=g++-10
endif

#

help:  ## Print this message
	@grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sort | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#

config: clean ## configure CMake
	@cd $(ORANGES_ROOT) && $(CMAKE) -B Builds -G $(CMAKE_GENERATOR) -D CMAKE_BUILD_TYPE=""

build: config ## runs CMake build
	@cd $(ORANGES_ROOT) && $(CMAKE) --build Builds --config ""

install: build ## runs CMake install
	@cd $(ORANGES_ROOT) && sudo $(CMAKE) --install Builds --config Release --strip --verbose

pack: install ## Creates a CPack installer
	@cd $(ORANGES_ROOT) && $(CPACK) -G "" -C Release --verbose

#

init:  ## Initializes the Lemons workspace and installs all dependencies
	@chmod +x $(ORANGES_ROOT)/scripts/alphabetize_codeowners.py
	@cd $(ORANGES_ROOT) && $(PRECOMMIT) install --install-hooks --overwrite
	@cd $(ORANGES_ROOT) && $(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg


pc:  ## Runs all pre-commit hooks over all files
	@cd $(ORANGES_ROOT) && git add . && $(PRECOMMIT) run --all-files

#

clean: ## Removes the builds directory
	$(RM) $(ORANGES_ROOT)/Builds

#

.PHONY: $(shell grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sed 's/:.*/\ /' | tr '\n' ' ')
