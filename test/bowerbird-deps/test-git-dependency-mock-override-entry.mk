# Mock test for git clone with entry override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the entry parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))/fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-entry:
	@mkdir -p $(WORKDIR_TEST)/$@/deps
	@touch $(WORKDIR_TEST)/$@/deps/overridden-entry.mk
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_ENTRY=true \
		mock-dep-override-entry.entry=overridden-entry.mk \
		$(WORKDIR_TEST)/$@/deps/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-entry)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_ENTRY
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-override-entry/deps/.
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-override-entry/deps/overridden-entry.mk

$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-entry, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-entry/deps, \
    url=https://mock.com/repo.git, \
    branch=main, \
    entry=default.mk))
endif

expected-git-dependency-mock-override-entry := \
	$(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://mock.com/repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-entry/deps,main,overridden-entry.mk)
