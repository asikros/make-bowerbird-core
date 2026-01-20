# Mock test for git clone with url override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the url parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))/fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-url:
	@mkdir -p $(WORKDIR_TEST)/$@/deps
	@touch $(WORKDIR_TEST)/$@/deps/lib.mk
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_URL=true \
		mock-dep-override-url.url=https://mock.com/overridden.git \
		$(WORKDIR_TEST)/$@/deps/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-url)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_URL
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-override-url/deps/.
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-override-url/deps/lib.mk

$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-url, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-url/deps, \
    url=https://mock.com/repo.git, \
    branch=develop, \
    entry=lib.mk))
endif

expected-git-dependency-mock-override-url := \
	$(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://mock.com/overridden.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-url/deps,develop,lib.mk)
