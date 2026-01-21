# Test for bowerbird-loader.mk bootstrapping
#
# Verifies that the loader correctly:
# - Downloads itself via curl
# - Clones the full repository
# - Makes bowerbird::core::git-dependency available

# Test setup
WORKDIR_DEPS := $(WORKDIR_TEST)/test-loader-bootstrap/deps

# Configure bowerbird-core loader
bowerbird-core.url ?= https://github.com/asikros/make-bowerbird-core.git
bowerbird-core.branch ?= main
bowerbird-core.path ?= $(WORKDIR_DEPS)/bowerbird-core

# Download the loader (simulating curl bootstrap)
$(bowerbird-core.path)/bowerbird-loader.mk:
	@mkdir -p $(dir $@)
	@cp $(CURDIR)/bowerbird-loader.mk $@

# Include the loader
include $(bowerbird-core.path)/bowerbird-loader.mk

# Test target
test-loader-bootstrap:
	@echo "Testing loader bootstrap..."
	@test -d $(bowerbird-core.path)/.git || (echo "ERROR: Repository not cloned" && exit 1)
	@test -f $(bowerbird-core.path)/bowerbird.mk || (echo "ERROR: Entry point missing" && exit 1)
	@test -f $(bowerbird-core.path)/src/bowerbird-core/bowerbird-deps.mk || (echo "ERROR: Core files missing" && exit 1)
	@echo "✓ Loader cloned repository successfully"
	@echo "✓ Entry point exists"
	@echo "✓ Core files are present"
	@# Verify that bowerbird::core::git-dependency is available
	@$(if $(value bowerbird::core::git-dependency),echo "✓ bowerbird::core::git-dependency macro is available",exit 1)
	@echo "SUCCESS: Loader bootstrap test passed"
