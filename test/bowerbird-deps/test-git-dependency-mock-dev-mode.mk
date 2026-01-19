# Mock test for git clone in dev mode
#
# Verifies that bowerbird::core::git-dependency generates correct
# git clone commands when --bowerbird-dev-mode is enabled.

include $(dir $(lastword $(MAKEFILE_LIST)))/fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-dev-mode:
	@mkdir -p $(WORKDIR_TEST)/$@/deps
	@touch $(WORKDIR_TEST)/$@/deps/main.mk
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_DEV=true \
		$(WORKDIR_TEST)/$@/deps/. -- --bowerbird-dev-mode
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-dev-mode)

ifdef TEST_GIT_DEPENDENCY_MOCK_DEV
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/deps/.
.PHONY: $(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/deps/main.mk

$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-dev, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/deps, \
    url=https://github.com/example/test-repo.git, \
    branch=develop, \
    entry=main.mk))
endif

expected-git-dependency-mock-dev-mode := \
	$(call bowerbird::core::test-fixture::expected-git-dependency,dev-mode,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-dev-mode/deps,develop,main.mk)
