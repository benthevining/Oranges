
CONFIG ?= Release

export CMAKE_BUILD_TYPE ?= $(CONFIG)
export CMAKE_CONFIG_TYPE ?= $(CONFIG)

export VERBOSE=1

# program aliases
RM = $(CMAKE) -E rm -rf
CMAKE ?= cmake
PRECOMMIT ?= pre-commit
GIT ?= git

# directory aliases
BUILDS ?= Builds
DOCS ?= doc
CACHE ?= Cache

DEPS_GRAPH ?= deps_graph

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
	export CC=gcc-10
	export CXX=g++-10
	SUDO ?= sudo
endif

#

override print_help = grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(THIS_MAKEFILE) | sort | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

override precommit_init = $(PRECOMMIT) install --install-hooks --overwrite && $(PRECOMMIT) install --install-hooks --overwrite --hook-type commit-msg

override run_precommit = $(GIT) add . && $(PRECOMMIT) run --all-files

override run_clean = $(RM) $(BUILDS) $(DOCS) $(DEPS_GRAPH).dot; $(PRECOMMIT) gc

override run_wipe_cache = $(SUDO) $(CMAKE) -P $(BUILDS)/wipe_cache.cmake

override run_uninstall = $(SUDO) $(CMAKE) -P $(BUILDS)/uninstall.cmake

#

override cmake_query_file_api = $(CMAKE) -D ORANGES_PROJECT_ROOT=$(1) -P $(1)/scripts/cmake_file_api/query_cmake_file_api.cmake

override cmake_configure_preset = $(CMAKE) --preset $(1)

override cmake_default_configure = $(CMAKE) -B $(BUILDS)

override cmake_build_preset = $(CMAKE) --build --preset $(1)

override cmake_default_build = $(CMAKE) --build $(BUILDS) --config $(CONFIG)

override cmake_install = $(SUDO) $(CMAKE) --install $(BUILDS) --config $(CONFIG) --strip

override cpack_create_installer = $(CMAKE) --build $(BUILDS) --target package
