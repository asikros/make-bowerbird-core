# Mock test for git clone with branch
#
# Verifies that bowerbird::core::git-dependency generates correct
# git clone commands for branch-based dependencies.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-branch:
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_BRANCH=true \
		$(WORKDIR_TEST)/$@/mock-dep/test.mk
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-branch)

ifdef TEST_GIT_DEPENDENCY_MOCK_BRANCH
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-branch, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-branch/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=main, \
    entry=test.mk))

# Create mock entry file to satisfy git-dependency's file check
$(WORKDIR_TEST)/test-git-dependency-mock-branch/mock-dep/test.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-branch/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-branch := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-branch/mock-dep,main,test.mk)
