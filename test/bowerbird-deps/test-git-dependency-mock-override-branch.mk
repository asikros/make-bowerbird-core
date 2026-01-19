# Mock test for git clone with branch override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the branch parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))/fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-branch:
	@mkdir -p $(WORKDIR_TEST)/$@/deps
	@touch $(WORKDIR_TEST)/$@/deps/entry.mk
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_BRANCH=true \
		mock-dep-override-branch.branch=feature-xyz \
		$(WORKDIR_TEST)/$@/deps/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-branch)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_BRANCH
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-override-branch/deps/.
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-override-branch/deps/entry.mk

$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-branch, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-branch/deps, \
    url=https://github.com/example/test-repo.git, \
    branch=main, \
    entry=entry.mk))
endif

expected-git-dependency-mock-override-branch := \
	$(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-branch/deps,feature-xyz,entry.mk)
