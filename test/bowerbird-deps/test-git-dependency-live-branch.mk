# Live integration test for git clone with branch
#
# Actually clones a real repository to verify end-to-end functionality.
# Requires network access. Set SKIP_LIVE_TESTS=1 to skip.

test-git-dependency-live-branch:
ifndef TEST_GIT_DEPENDENCY_LIVE_BRANCH
	$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_BRANCH=true $(WORKDIR_TEST)/$@/deps/bowerbird.mk
else
	@test -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Clone failed - directory not created" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird.mk || (echo "ERROR: Entry point not found" && exit 1)
	@test ! -d $(WORKDIR_TEST)/$@/deps/.git || (echo "ERROR: .git should be removed (not in dev mode)" && exit 1)

$(call bowerbird::core::git-dependency, \
    name=live-test-branch, \
    path=$(WORKDIR_TEST)/test-git-dependency-live-branch/deps, \
    url=https://github.com/asikros/make-bowerbird-core.git, \
    branch=main, \
    entry=bowerbird.mk)
endif
