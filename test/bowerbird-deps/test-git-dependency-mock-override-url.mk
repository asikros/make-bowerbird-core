# Mock test for git clone with url override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the url parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-url:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_URL=true \
		mock-dep-override-url.url=https://github.com/overridden/repo.git \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-url)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_URL
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-url, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-url/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=develop, \
    entry=lib.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-override-url/mock-dep/lib.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-override-url/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-override-url := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/overridden/repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-url/mock-dep,develop,lib.mk)
