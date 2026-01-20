# Project
NAME := bowerbird-core
VERSION := $(shell git describe --always --dirty --broken 2> /dev/null || echo "unknown")

# Constants
.DEFAULT_GOAL := help

# Targets
.PHONY: check
check: ## Runs all repository tests
check: private_check

.PHONY: clean
clean: ## Deletes all files created by Make
clean: private_clean

# Includes
include make/private.mk
