# Mock test for git clone in dev mode
#
# Verifies that bowerbird::core::git-dependency generates correct
# git clone commands when --bowerbird-dev-mode is enabled.

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-dev-mode:
	test ! -d $(WORKDIR_TEST)/$@/mock-dep || rm -rf $(WORKDIR_TEST)/$@/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_DEV=true \
		$(WORKDIR_TEST)/$@/mock-dep/. -- --bowerbird-dev-mode
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-dev-mode)

ifdef TEST_GIT_DEPENDENCY_MOCK_DEV
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-dev, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=develop, \
    entry=main.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/mock-dep/main.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-dev-mode := $(call bowerbird::core::test-fixture::expected-git-dependency,dev-mode,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/mock-dep,develop,main.mk)
