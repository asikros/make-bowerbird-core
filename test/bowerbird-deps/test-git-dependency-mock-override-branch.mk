# Mock test for git clone with branch override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the branch parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-branch:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_BRANCH=true \
		mock-dep-override-branch.branch=feature-xyz \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-branch)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_BRANCH
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-branch, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-branch/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=main, \
    entry=entry.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-override-branch/mock-dep/entry.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-override-branch/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-override-branch := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-branch/mock-dep,feature-xyz,entry.mk)
