# Mock test for git clone with revision
#
# Verifies that bowerbird::core::git-dependency generates correct
# git clone commands for revision-based dependencies.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-revision:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_REVISION=true \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-revision)

ifdef TEST_GIT_DEPENDENCY_MOCK_REVISION
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-revision, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-revision/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    revision=abc123def456789, \
    entry=lib.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-revision/mock-dep/lib.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-revision/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-revision := $(call bowerbird::core::test-fixture::expected-git-dependency,revision,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-revision/mock-dep,abc123def456789,lib.mk)
