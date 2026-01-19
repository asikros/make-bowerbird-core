# Mock test for git clone with path override
#
# Verifies that bowerbird::core::git-dependency respects command-line
# override of the path parameter.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-override-path:
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_PATH=true \
		mock-dep-override-path.path=$(WORKDIR_TEST)/test-git-dependency-mock-override-path/overridden-path \
		$(WORKDIR_TEST)/$@/overridden-path/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-override-path)

ifdef TEST_GIT_DEPENDENCY_MOCK_OVERRIDE_PATH
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-override-path, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-override-path/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=main, \
    entry=bowerbird.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-override-path/overridden-path/bowerbird.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-override-path/overridden-path/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-override-path := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-override-path/overridden-path,main,bowerbird.mk)
