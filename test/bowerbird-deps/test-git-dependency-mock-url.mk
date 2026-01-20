# Mock test for git clone with different URL formats
#
# Verifies that bowerbird::core::git-dependency handles various URL formats
# like https://mock.com/group/subgroup/project.git

include $(dir $(lastword $(MAKEFILE_LIST)))/fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-url:
	@mkdir -p $(WORKDIR_TEST)/$@/deps
	@touch $(WORKDIR_TEST)/$@/deps/bowerbird.mk
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_URL=true \
		$(WORKDIR_TEST)/$@/deps/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-url)

ifdef TEST_GIT_DEPENDENCY_MOCK_URL
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-url/deps/.
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-url/deps/bowerbird.mk

$(call bowerbird::core::git-dependency, \
    name=mock-dep-url, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-url/deps, \
    url=https://mock.com/group/subgroup/project.git, \
    branch=main, \
    entry=bowerbird.mk)
endif

expected-git-dependency-mock-url := \
	$(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://mock.com/group/subgroup/project.git,$(WORKDIR_TEST)/test-git-dependency-mock-url/deps,main,bowerbird.mk)
