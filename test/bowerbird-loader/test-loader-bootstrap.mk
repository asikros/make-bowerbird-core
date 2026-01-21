# Test for bowerbird-loader.mk bootstrapping
#
# Verifies that the loader correctly:
# - Downloads itself via curl
# - Clones the full repository
# - Makes bowerbird::core::git-dependency available

# Capture the path to this test file (evaluated at parse-time, outside ifdef)
TEST_LOADER_BOOTSTRAP_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifdef TEST_LOADER_BOOTSTRAP
bowerbird-core.path ?= $(WORKDIR_DEPS)/bowerbird-core
bowerbird-core.url ?= https://github.com/asikros/make-bowerbird-core.git
bowerbird-core.branch ?= main
bowerbird-core.entry ?= bowerbird.mk

$(WORKDIR_DEPS)/bowerbird-loader.mk:
	@mkdir -p $(dir $@)
	@cp $(TEST_LOADER_BOOTSTRAP_DIR)../../bowerbird-loader.mk $@

include $(WORKDIR_DEPS)/bowerbird-loader.mk
endif

# Test target
test-loader-bootstrap:
	@$(MAKE) -j1 TEST_LOADER_BOOTSTRAP=true WORKDIR_DEPS=$(WORKDIR_TEST)/$@/deps MAKECMDGOALS=
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird-loader.mk || (echo "ERROR: Loader not downloaded" && exit 1)
	@test -d $(WORKDIR_TEST)/$@/deps/bowerbird-core/.git || (echo "ERROR: Repository not cloned" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird-core/bowerbird.mk || (echo "ERROR: Entry point missing" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird-core/src/bowerbird-core/bowerbird-deps.mk || (echo "ERROR: Core files missing" && exit 1)
	@echo "SUCCESS: Loader bootstrap test passed"
