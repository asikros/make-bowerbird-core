# Live integration test for git clone with tag
#
# Verifies that cloning with a git tag works correctly.
# Uses semantic versioning format (MAJOR.MINOR.PATCH) without 'v' prefix.
# Requires network access.
#
# NOTE: Commented out until a tag is created in the repository.
#       To enable: create a tag (e.g., 1.0.0) and push it, then uncomment below.

# ifdef TEST_GIT_DEPENDENCY_LIVE_TAG
# $(call bowerbird::core::git-dependency, \
#     name=live-test-tag, \
#     path=$(WORKDIR_TEST)/test-git-dependency-live-tag/deps, \
#     url=https://github.com/asikros/make-bowerbird-core.git, \
#     branch=1.0.0, \
#     entry=bowerbird.mk)
# endif
# 
# test-git-dependency-live-tag:
# 	@$(MAKE) -j1 TEST_GIT_DEPENDENCY_LIVE_TAG=true $(WORKDIR_TEST)/$@/deps/bowerbird.mk
# 	@test -d $(WORKDIR_TEST)/$@/deps || (echo "ERROR: Clone failed - directory not created" && exit 1)
# 	@test -f $(WORKDIR_TEST)/$@/deps/bowerbird.mk || (echo "ERROR: Entry point not found" && exit 1)
# 	@test ! -d $(WORKDIR_TEST)/$@/deps/.git || (echo "ERROR: .git should be removed (not in dev mode)" && exit 1)
