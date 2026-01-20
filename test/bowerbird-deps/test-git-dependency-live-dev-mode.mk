# Live integration test for git clone with --bowerbird-dev-mode
#
# Verifies that .git directory is preserved in dev mode.
# Requires network access. Set SKIP_LIVE_TESTS=1 to skip.

test-git-dependency-live-dev-mode:
ifndef SKIP_LIVE_TESTS
	@echo "Running live test: clone with dev mode..."
	@rm -rf $(WORKDIR_TEST)/$@/deps
	@mkdir -p $(WORKDIR_TEST)/$@
	$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_DEV_MODE=true --bowerbird-dev-mode $(WORKDIR_TEST)/$@/deps/bowerbird.mk
	@test -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Clone failed - directory not created" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird.mk || (echo "ERROR: Entry point not found" && exit 1)
	@test -d $(WORKDIR_TEST)/$@/deps/.git || (echo "ERROR: .git should be preserved in dev mode" && exit 1)
	@cd $(WORKDIR_TEST)/$@/deps && git log -1 --oneline > /dev/null || (echo "ERROR: .git directory is not functional" && exit 1)
	@echo "✓ Live test passed: dev mode preserves .git"
	@rm -rf $(WORKDIR_TEST)/$@
else
	@echo "Skipping live test (SKIP_LIVE_TESTS=1)"
endif

ifdef TEST_GIT_DEPENDENCY_LIVE_DEV_MODE
$(call bowerbird::core::git-dependency, \
    name=live-test-dev-mode, \
    path=$(WORKDIR_TEST)/test-git-dependency-live-dev-mode/deps, \
    url=https://github.com/asikros/make-bowerbird-core.git, \
    branch=main, \
    entry=bowerbird.mk)
endif
