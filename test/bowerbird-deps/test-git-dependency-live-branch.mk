# Live integration test for git clone with branch
#
# Actually clones a real repository to verify end-to-end functionality.
# Requires network access. Set SKIP_LIVE_TESTS=1 to skip.

test-git-dependency-live-branch:
ifndef SKIP_LIVE_TESTS
	@echo "Running live test: clone with branch..."
	@rm -rf $(WORKDIR_TEST)/$@/deps
	@mkdir -p $(WORKDIR_TEST)/$@
	$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_BRANCH=true $(WORKDIR_TEST)/$@/deps/bowerbird.mk
	@test -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Clone failed - directory not created" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird.mk || (echo "ERROR: Entry point not found" && exit 1)
	@test ! -d $(WORKDIR_TEST)/$@/deps/.git || (echo "ERROR: .git should be removed (not in dev mode)" && exit 1)
	@echo "✓ Live test passed: branch clone"
	@rm -rf $(WORKDIR_TEST)/$@
else
	@echo "Skipping live test (SKIP_LIVE_TESTS=1)"
endif

ifdef TEST_GIT_DEPENDENCY_LIVE_BRANCH
$(call bowerbird::core::git-dependency, \
    name=live-test-branch, \
    path=$(WORKDIR_TEST)/test-git-dependency-live-branch/deps, \
    url=https://github.com/asikros/make-bowerbird-core.git, \
    branch=main, \
    entry=bowerbird.mk)
endif
