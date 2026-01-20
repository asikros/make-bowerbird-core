# Project
NAME := bowerbird-core
VERSION := $(shell git describe --always --dirty --broken 2> /dev/null || echo "unknown")

# Constants
.DEFAULT_GOAL := help

# Targets
.PHONY: check
check: ## Runs all repository tests (mock + live)
check: check-mock check-live

.PHONY: check-mock
check-mock: ## Runs mock tests (fast, no network)
check-mock: private_check_mock

.PHONY: check-live
check-live: ## Runs live integration tests (requires network)
check-live: private_check_live

.PHONY: clean
clean: ## Deletes all files created by Make
clean: private_clean

# Includes
include make/private.mk
