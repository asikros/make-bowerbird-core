# Mock test for git clone with tag as branch
#
# Verifies that bowerbird::core::git-dependency handles git tags
# specified via the branch parameter like v1.2.3

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-tag:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_TAG=true \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-tag)

ifdef TEST_GIT_DEPENDENCY_MOCK_TAG
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-tag, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-tag/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=v1.2.3, \
    entry=bowerbird.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-tag/mock-dep/bowerbird.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-tag/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-tag := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-tag/mock-dep,v1.2.3,bowerbird.mk)
