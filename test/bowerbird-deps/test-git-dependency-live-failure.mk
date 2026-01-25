# Live integration test for git clone failure cleanup
#
# Verifies that failed clones clean up partial directories.
# Requires network access.

ifdef TEST_GIT_DEPENDENCY_LIVE_FAILURE
# Use an invalid TLD to force instant DNS failure (no long timeout)
$(call bowerbird::core::git-dependency, \
		name=live-test-failure, \
		path=$(WORKDIR_TEST)/test-git-dependency-live-failure/deps, \
		url=https://nonexistent-repo.invalid/repo.git, \
		branch=main, \
		entry=should-not-exist.mk)
endif

test-git-dependency-live-failure:
	@$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_FAILURE=true $(WORKDIR_TEST)/$@/deps/should-not-exist.mk 2>&1 | grep -q "ERROR: Failed to setup dependency" || (echo "ERROR: Expected error message not found" && exit 1)
	@test ! -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Failed clone should clean up directory" && exit 1)
