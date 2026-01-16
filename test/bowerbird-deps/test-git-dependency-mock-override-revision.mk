# Mock test for git clone with revision override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the revision parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-revision:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_REVISION=true \
		mock-dep-override-revision.revision=fedcba987654321 \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-revision)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_REVISION
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-revision, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-revision/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    revision=abc123def456789, \
    entry=main.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-override-revision/mock-dep/main.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-override-revision/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-override-revision := $(call bowerbird::core::test-fixture::expected-git-dependency,revision,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-revision/mock-dep,fedcba987654321,main.mk)
