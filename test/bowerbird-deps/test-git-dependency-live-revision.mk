# Live integration test for git clone with specific revision
#
# Actually clones a real repository at a specific commit SHA.
# Requires network access. Set SKIP_LIVE_TESTS=1 to skip.

test-git-dependency-live-revision:
ifndef TEST_GIT_DEPENDENCY_LIVE_REVISION
	$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_REVISION=true $(WORKDIR_TEST)/$@/deps/bowerbird.mk
else
	@test -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Clone failed - directory not created" && exit 1)
	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird.mk || (echo "ERROR: Entry point not found" && exit 1)
	@test ! -d $(WORKDIR_TEST)/$@/deps/.git || (echo "ERROR: .git should be removed (not in dev mode)" && exit 1)

ifdef TEST_GIT_DEPENDENCY_LIVE_REVISION
# Use a recent commit from make-bowerbird-core main branch
$(call bowerbird::core::git-dependency, \
    name=live-test-revision, \
    path=$(WORKDIR_TEST)/test-git-dependency-live-revision/deps, \
    url=https://github.com/asikros/make-bowerbird-core.git, \
    revision=cbc6bddd8815e07c45a0ce5ec2fa2b7ebc6abdb9, \
    entry=bowerbird.mk)
endif
