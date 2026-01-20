# Live integration test for git clone failure cleanup
#
# Verifies that failed clones clean up partial directories.
# Requires network access. Set SKIP_LIVE_TESTS=1 to skip.

test-git-dependency-live-failure:
ifndef TEST_GIT_DEPENDENCY_LIVE_FAILURE
	$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_FAILURE=true $(WORKDIR_TEST)/$@/deps/should-not-exist.mk 2>&1 | grep -q "ERROR: Failed to setup dependency" || (echo "ERROR: Expected error message not found" && exit 1)
else
	@test ! -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Failed clone should clean up directory" && exit 1)

ifdef TEST_GIT_DEPENDENCY_LIVE_FAILURE
# Use an invalid URL to force a clone failure
$(call bowerbird::core::git-dependency, \
    name=live-test-failure, \
    path=$(WORKDIR_TEST)/test-git-dependency-live-failure/deps, \
    url=https://github.com/nonexistent-org-12345/nonexistent-repo-67890.git, \
    branch=main, \
    entry=should-not-exist.mk)
endif
