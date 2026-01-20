# Live integration test for git clone failure cleanup
#
# Verifies that failed clones clean up partial directories.
# Requires network access.

ifdef TEST_GIT_DEPENDENCY_LIVE_FAILURE
# Use an invalid URL to force a clone failure
$(call bowerbird::core::git-dependency, \
    name=live-test-failure, \
    path=$(WORKDIR_TEST)/test-git-dependency-live-failure/deps, \
    url=https://github.com/nonexistent-org-12345/nonexistent-repo-67890.git, \
    branch=main, \
    entry=should-not-exist.mk)
endif

test-git-dependency-live-failure:
	@$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_FAILURE=true BOWERBIRD_GIT_LOW_SPEED_LIMIT=10 BOWERBIRD_GIT_LOW_SPEED_TIME=3 BOWERBIRD_GIT_TIMEOUT=5 $(WORKDIR_TEST)/$@/deps/should-not-exist.mk 2>&1 | grep -q "ERROR: Failed to setup dependency" || (echo "ERROR: Expected error message not found" && exit 1)
	@test ! -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Failed clone should clean up directory" && exit 1)
