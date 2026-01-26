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
private_clean: PATHS_CLEAN = $(WORKDIR_DEPS) $(WORKDIR_ROOT) $(WORKDIR_TEST)
private_clean:
	@\echo "Cleaning directories:"
	$(foreach path,$(PATHS_CLEAN),$(if $(wildcard $(path)), \rm -rfv $(path);))
	@\echo


.PHONY: private_mostlyclean
private_mostlyclean: PATHS_CLEAN = $(WORKDIR_TEST)
private_mostlyclean:
	@\echo "Cleaning directories:"
	$(foreach path,$(PATHS_CLEAN),$(if $(wildcard $(path)), \rm -rfv $(path);))
	@\echo

ifdef bowerbird::test::suite
$(call bowerbird::test::suite,private_check,test,test*.mk,test*)
endif
