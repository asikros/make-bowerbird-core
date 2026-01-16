# Mock tests for clean target
#
# Verifies that the clean target generates correct rm commands with safety checks

include $(dir $(lastword $(MAKEFILE_LIST)))fixture-clean-expected.mk

_CURDIR := $(CURDIR)
_HOME := $(HOME)

test-makefile-clean-single-path:
	@mkdir -p $(WORKDIR_TEST)/$@
	@: > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 clean \
		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		PATHS_CLEAN="$(WORKDIR_TEST)/$@"
	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-clean-single-path)

expected-clean-single-path := $(call bowerbird::test-fixture::expected-clean,$(WORKDIR_TEST)/test-makefile-clean-single-path)

# test-makefile-clean-multiple-paths:
# 	@mkdir -p $(WORKDIR_TEST)/$@/mock-path/deps
# 	@: > $(WORKDIR_TEST)/$@/results
# 	$(MAKE) -j1 clean \
# 		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
# 		PATHS_CLEAN="$(WORKDIR_TEST)/$@/mock-path/deps $(WORKDIR_TEST)/$@/mock-path" \
# 		2>/dev/null || true
# 	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-clean-multiple-paths)

# expected-clean-multiple-paths := $(call bowerbird::test-fixture::expected-clean,$(WORKDIR_TEST)/test-makefile-clean-multiple-paths/mock-path/deps $(WORKDIR_TEST)/test-makefile-clean-multiple-paths/mock-path)

# test-makefile-clean-no-paths-exist:
# 	@mkdir -p $(WORKDIR_TEST)/$@
# 	@: > $(WORKDIR_TEST)/$@/results
# 	$(MAKE) -j1 \
# 		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
# 		PATHS_CLEAN="$(WORKDIR_TEST)/$@/nonexistent" \
# 		clean 2>/dev/null || true
# 	$(call bowerbird::test::compare-file-content-from-var,$(WORKDIR_TEST)/$@/results,expected-clean-no-paths)

# define expected-clean-no-paths
# echo "INFO: Cleaning directories"
# echo "INFO: Cleaning complete"
# echo
# endef
