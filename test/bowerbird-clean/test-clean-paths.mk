# Tests for bowerbird::core::clean-paths macro
#
# Verifies that the clean-paths macro generates correct rm commands with safety checks

define bowerbird::test-fixture::expected-clean
echo "INFO: Cleaning directories"
$(foreach path,$1,test -n "$(path)" || (>&2 echo "ERROR: Empty path in cleanup" && exit 1); test "$(path)" != "/" || (>&2 echo "ERROR: Cannot delete root" && exit 1); test "$(path)" != "$(HOME)" || (>&2 echo "ERROR: Cannot delete HOME" && exit 1); echo "$(path)" | grep -q "$(CURDIR)" || (>&2 echo "ERROR: Path must be under project dir: $(path)" && exit 1); rm -rfv -- "$(path)";)\

echo "INFO: Cleaning complete"
echo
endef


# Test: clean single path
test-clean-paths-single:
	@mkdir -p $(WORKDIR_TEST)/$@/test-dir
	@: > $(WORKDIR_TEST)/$@/results
	$(eval CLEAN_TEST_PATHS = $(WORKDIR_TEST)/$@/test-dir)
	$(MAKE) -j1 __test-clean-paths-invoke \
		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		CLEAN_TEST_PATHS="$(CLEAN_TEST_PATHS)"
	$(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/results,\
		expected-clean-paths-single)


expected-clean-paths-single := \
		$(call bowerbird::test-fixture::expected-clean,\
		$(WORKDIR_TEST)/test-clean-paths-single/test-dir)


# Test: clean multiple paths
test-clean-paths-multiple:
	@mkdir -p $(WORKDIR_TEST)/$@/path1
	@mkdir -p $(WORKDIR_TEST)/$@/path2
	@mkdir -p $(WORKDIR_TEST)/$@/path3
	@: > $(WORKDIR_TEST)/$@/results
	$(eval CLEAN_TEST_PATHS = $(WORKDIR_TEST)/$@/path1 $(WORKDIR_TEST)/$@/path2 $(WORKDIR_TEST)/$@/path3)
	$(MAKE) -j1 __test-clean-paths-invoke \
		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		CLEAN_TEST_PATHS="$(CLEAN_TEST_PATHS)"
	$(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/results,\
		expected-clean-paths-multiple)


expected-clean-paths-multiple := \
		$(call bowerbird::test-fixture::expected-clean,\
		$(WORKDIR_TEST)/test-clean-paths-multiple/path1 \
		$(WORKDIR_TEST)/test-clean-paths-multiple/path2 \
		$(WORKDIR_TEST)/test-clean-paths-multiple/path3)


# Test: clean non-existent paths (should be skipped)
test-clean-paths-nonexistent:
	@mkdir -p $(WORKDIR_TEST)/$@
	@: > $(WORKDIR_TEST)/$@/results
	$(eval CLEAN_TEST_PATHS = $(WORKDIR_TEST)/$@/does-not-exist)
	$(MAKE) -j1 __test-clean-paths-invoke \
		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		CLEAN_TEST_PATHS="$(CLEAN_TEST_PATHS)"
	$(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/results,\
		expected-clean-paths-nonexistent)


define expected-clean-paths-nonexistent
echo "INFO: Cleaning directories"
echo "INFO: Cleaning complete"
echo
endef


# Helper target that invokes the clean-paths macro
.PHONY: __test-clean-paths-invoke
__test-clean-paths-invoke:
	$(call bowerbird::core::clean-paths,$(CLEAN_TEST_PATHS))
