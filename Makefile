SHELL = /bin/sh
.ONESHELL:
.SHELLFLAGS: -euo
.DEFAULT_GOAL: help
.NOTPARALLEL:
.POSIX:

#

PRECOMMIT = pre-commit

override ORANGES_ROOT := $(patsubst %/,%,$(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

override THIS_MAKEFILE := $(ORANGES_ROOT)/Makefile

#

help:  ## Print this message
	@grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sort | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#

init:  ## Initializes the Lemons workspace and installs all dependencies
	@chmod +x $(ORANGES_ROOT)/scripts/alphabetize_codeowners.py
	@cd $(ORANGES_ROOT) && $(PRECOMMIT) install --install-hooks --overwrite
	@cd $(ORANGES_ROOT) && $(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg


pc:  ## Runs all pre-commit hooks over all files
	@cd $(ORANGES_ROOT) && git add . && $(PRECOMMIT) run --all-files

#

.PHONY: $(shell grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sed 's/:.*/\ /' | tr '\n' ' ')
