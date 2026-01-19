# Mock test for git clone with nested entry path
#
# Verifies that bowerbird::core::git-dependency handles nested
# entry point paths like src/lib/bowerbird.mk

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-entry:
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_ENTRY=true \
		$(WORKDIR_TEST)/$@/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-entry)

ifdef TEST_GIT_DEPENDENCY_MOCK_ENTRY
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-entry, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-entry/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=main, \
    entry=src/lib/bowerbird.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-entry/mock-dep/src/lib/bowerbird.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-entry/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-entry := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-entry/mock-dep,main,src/lib/bowerbird.mk)
