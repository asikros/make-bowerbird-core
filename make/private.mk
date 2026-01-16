# Config
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
MAKEFLAGS += --jobs
MAKEFLAGS += --check-symlink-times
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --print-directory
MAKEFLAGS += --warn-undefined-variables

# Shell
.SHELLFLAGS = -euc
SHELL = /bin/sh

# Paths
WORKDIR_ROOT := $(CURDIR)/.make
WORKDIR_BUILD = $(WORKDIR_ROOT)/build
WORKDIR_DEPS = $(WORKDIR_ROOT)/deps
WORKDIR_TEST = $(WORKDIR_ROOT)/test/$(NAME)/$(VERSION)

# Includes
include bowerbird.mk
include make/deps.mk

# Targets

# private_clean
#
#	Removes build artifacts and temporary directories (WORKDIR_DEPS, WORKDIR_ROOT, WORKDIR_TEST)
#	with safety checks.
#
#	Validates each path before deletion to prevent accidental removal of:
#		Root directory (/).
#		Home directory ($HOME).
#		Directories outside the project.
#		Empty paths.
#
.PHONY: private_clean
private_clean: PATHS_CLEAN = $(WORKDIR_DEPS) $(WORKDIR_ROOT) $(WORKDIR_TEST)
private_clean:
	@echo "INFO: Cleaning directories"
	$(foreach path,$(PATHS_CLEAN),\
		$(if $(wildcard $(path)),\
			test -n "$(path)" || (>&2 echo "ERROR: Empty path in cleanup" && exit 1); \
			test "$(path)" != "/" || (>&2 echo "ERROR: Cannot delete root" && exit 1); \
			test "$(path)" != "$(HOME)" || (>&2 echo "ERROR: Cannot delete HOME" && exit 1); \
			echo "$(path)" | grep -q "$(CURDIR)" || (>&2 echo "ERROR: Path must be under project dir: $(path)" && exit 1); \
			\rm -rfv -- "$(path)";)\
	)
	@echo "INFO: Cleaning complete"
	@echo

ifdef bowerbird::test::suite
$(call bowerbird::test::suite,private_test,test,test*.mk,test*)
endif
