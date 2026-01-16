# Simple functional tests for Makefile targets

# Test: check target exists
test-makefile-targets-exist-check:
	@$(MAKE) -p 2>/dev/null | grep -q "^check:" || (echo "ERROR: check target not found" && exit 1)

# Test: clean target exists
test-makefile-targets-exist-clean:
	@$(MAKE) -p 2>/dev/null | grep -q "^clean:" || (echo "ERROR: clean target not found" && exit 1)

# Test: help target exists
test-makefile-targets-exist-help:
	@$(MAKE) -p 2>/dev/null | grep -q "^help:" || (echo "ERROR: help target not found" && exit 1)

# Test: help is default goal
test-makefile-targets-exist-default-goal-is-help:
	@$(MAKE) -p 2>/dev/null | grep "^.DEFAULT_GOAL" | grep -q "help" || (echo "ERROR: default goal is not help" && exit 1)

# Test: help target runs successfully
test-makefile-targets-exist-help-runs:
	@$(MAKE) help >/dev/null 2>&1 || (echo "ERROR: help target failed to run" && exit 1)
