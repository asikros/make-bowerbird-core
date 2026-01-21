# Test for bowerbird-loader.mk bootstrapping
#
# Verifies that the loader correctly:
# - Downloads itself via curl
# - Clones the full repository
# - Makes bowerbird::core::git-dependency available

ifdef TEST_LOADER_BOOTSTRAP
# Configure bowerbird-core loader
bowerbird-core.url ?= https://github.com/asikros/make-bowerbird-core.git
bowerbird-core.branch ?= main
bowerbird-core.path ?= $(WORKDIR_TEST)/test-loader-bootstrap/deps/bowerbird-core

# Download the loader (simulating curl bootstrap)
$(bowerbird-core.path)/bowerbird-loader.mk:
	@mkdir -p $(dir $@)
	@cp $(CURDIR)/bowerbird-loader.mk $@

# Include the loader
include $(bowerbird-core.path)/bowerbird-loader.mk
endif

# Test target
test-loader-bootstrap:
	@$(MAKE) -j1 TEST_LOADER_BOOTSTRAP=true $(WORKDIR_TEST)/$@/deps/bowerbird-core/bowerbird.mk
	@test -d $(WORKDIR_TEST)/$@/deps/bowerbird-core/.git || (echo "ERROR: Repository not cloned" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird-core/bowerbird.mk || (echo "ERROR: Entry point missing" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird-core/src/bowerbird-core/bowerbird-deps.mk || (echo "ERROR: Core files missing" && exit 1)
	@echo "✓ Loader cloned repository successfully"
	@echo "✓ Entry point exists"
	@echo "✓ Core files are present"
	@echo "SUCCESS: Loader bootstrap test passed"
