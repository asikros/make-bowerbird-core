# Mock test for git clone with nested installation path
#
# Verifies that bowerbird::core::git-dependency handles deeply nested
# installation paths like deps/vendor/mock-dep

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-git-dependency-mock-expected.mk

test-git-dependency-mock-path:
	test ! -d $(WORKDIR_TEST)/$@/deps/vendor/mock-dep || rm -rf $(WORKDIR_TEST)/$@/deps/vendor/mock-dep
	@mkdir -p $(WORKDIR_TEST)/$@
	@cat /dev/null > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		TEST_GIT_DEPENDENCY_MOCK_PATH=true \
		$(WORKDIR_TEST)/$@/deps/vendor/mock-dep/.
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-git-dependency-mock-path)

ifdef TEST_GIT_DEPENDENCY_MOCK_PATH
$(eval $(call bowerbird::core::git-dependency, \
    name=mock-dep-path, \
    path=$(WORKDIR_TEST)/test-git-dependency-mock-path/deps/vendor/mock-dep, \
    url=https://github.com/example/test-repo.git, \
    branch=main, \
    entry=bowerbird.mk))

$(WORKDIR_TEST)/test-git-dependency-mock-path/deps/vendor/mock-dep/bowerbird.mk: | $(WORKDIR_TEST)/test-git-dependency-mock-path/deps/vendor/mock-dep/.
	@mkdir -p $(dir $@)
	@touch $@
endif

expected-git-dependency-mock-path := $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/test-repo.git,$(WORKDIR_TEST)/test-git-dependency-mock-path/deps/vendor/mock-dep,main,bowerbird.mk)
