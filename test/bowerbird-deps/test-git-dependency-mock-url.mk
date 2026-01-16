# Mock test for git clone with different URL formats
#
# Verifies that bowerbird::core::git-dependency handles various URL formats
# like https://gitlab.com/group/subgroup/project.git

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-url:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_URL=true \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-url)

ifdef TEST_GIT_DEPENDENCY_MOCK_URL
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-url, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-url/mock-dep, \
    url=https://gitlab.com/group/subgroup/project.git, \
    branch=main, \
    entry=bowerbird.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-url/mock-dep/bowerbird.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-url/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-url := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://gitlab.com/group/subgroup/project.git,$(WORKDIR_TEST)/test-git-dependency-mock-url/mock-dep,main,bowerbird.mk)
