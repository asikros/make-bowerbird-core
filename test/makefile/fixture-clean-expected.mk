# Fixture for generating expected clean command output
#
# Usage: $(call bowerbird::test-fixture::expected-clean,path1,path2,...)
#
# Generates expected mock output for private_clean with given paths
# CURDIR and HOME are captured from the test environment

define bowerbird::test-fixture::expected-clean
echo "INFO: Cleaning directories"
$(foreach path,$1,test -n "$(path)" || (>&2 echo "ERROR: Empty path in cleanup" && exit 1); test "$(path)" != "/" || (>&2 echo "ERROR: Cannot delete root" && exit 1); test "$(path)" != "$(HOME)" || (>&2 echo "ERROR: Cannot delete HOME" && exit 1); echo "$(path)" | grep -q "$(CURDIR)" || (>&2 echo "ERROR: Path must be under project dir: $(path)" && exit 1); rm -rfv -- "$(path)";) 
echo "INFO: Cleaning complete"
echo
endef
