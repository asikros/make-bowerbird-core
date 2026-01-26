# Mock tests for clean target
#
# Verifies that the clean target generates correct rm commands with safety checks

define bowerbird::test-fixture::expected-clean
echo "INFO: Cleaning directories"
$(foreach path,$1,test -n "$(path)" || (>&2 echo "ERROR: Empty path in cleanup" && exit 1); test "$(path)" != "/" || (>&2 echo "ERROR: Cannot delete root" && exit 1); test "$(path)" != "$(HOME)" || (>&2 echo "ERROR: Cannot delete HOME" && exit 1); echo "$(path)" | grep -q "$(CURDIR)" || (>&2 echo "ERROR: Path must be under project dir: $(path)" && exit 1); rm -rfv -- "$(path)";)\

echo "INFO: Cleaning complete"
echo
endef


test-makefile-clean-single-path:
	@mkdir -p $(WORKDIR_TEST)/$@
	@: > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 clean \
		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		PATHS_CLEAN="$(WORKDIR_TEST)/$@"
	$(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/results,\
		expected-clean-single-path)


expected-clean-single-path := \
		$(call bowerbird::test-fixture::expected-clean,\
		$(WORKDIR_TEST)/test-makefile-clean-single-path)


test-makefile-clean-multiple-paths:
	@mkdir -p $(WORKDIR_TEST)/$@/path1
	@mkdir -p $(WORKDIR_TEST)/$@/path2
	@mkdir -p $(WORKDIR_TEST)/$@/path3
	@: > $(WORKDIR_TEST)/$@/results
	$(MAKE) -j1 clean \
		BOWERBIRD_MOCK_RESULTS=$(WORKDIR_TEST)/$@/results \
		PATHS_CLEAN="$(WORKDIR_TEST)/$@/path1 $(WORKDIR_TEST)/$@/path2 $(WORKDIR_TEST)/$@/path3"
	$(call bowerbird::test::compare-file-content-from-var,\
		$(WORKDIR_TEST)/$@/results,\
		expected-clean-multiple-paths)


expected-clean-multiple-paths := \
		$(call bowerbird::test-fixture::expected-clean,\
		$(WORKDIR_TEST)/test-makefile-clean-multiple-paths/path1 \
		$(WORKDIR_TEST)/test-makefile-clean-multiple-paths/path2 \
		$(WORKDIR_TEST)/test-makefile-clean-multiple-paths/path3)


