# Config
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
.PHONY: private_clean
private_clean: PATHS_CLEAN = $(WORKDIR_BUILD) $(WORKDIR_DEPS) $(WORKDIR_ROOT) $(WORKDIR_TEST)
private_clean:
	$(call bowerbird::core::clean-paths,$(PATHS_CLEAN))

ifdef bowerbird::test::suite
$(call bowerbird::test::suite,private_check,test,test*.mk,test*)
endif
