# Mock test for git clone with revision
#
# Verifies that bowerbird::core::git-dependency generates correct
# git clone commands for revision-based dependencies.

include $(dir $(lastword $(MAKEFILE_LIST)))/fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-revision:
	@mkdir -p $(WORKDIR_TEST)/$@/deps
	@touch $(WORKDIR_TEST)/$@/deps/lib.mk
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_REVISION=true \
		$(WORKDIR_TEST)/$@/deps/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-revision)

ifdef TEST_GIT_DEPENDENCY_MOCK_REVISION
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-revision/deps/.
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-revision/deps/lib.mk

$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-revision, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-revision/deps, \
    url=https://mock.com/repo.git, \
    revision=abc123def456789, \
    entry=lib.mk))
endif

expected-git-dependency-mock-revision := \
	$(call bowerbird::core::test-fixture::expected-git-dependency,revision,https://mock.com/repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-revision/deps,abc123def456789,lib.mk)
