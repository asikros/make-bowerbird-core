# Integration tests for WORKDIR variables
#
# Verifies that WORKDIR variables are properly used throughout the system
# and can be easily overridden for testing and customization.

test-workdir-test:
	$(MAKE) \
		TEST_WORKDIR_TEST=true \
		WORKDIR_TEST=$(WORKDIR_TEST)/$@ \
		mock-workdir-test-suite 2>/dev/null
	test -f $(WORKDIR_TEST)/$@/artifact

ifdef TEST_WORKDIR_TEST
.PHONY: mock-workdir-test-artifact
mock-workdir-test-artifact: $(WORKDIR_TEST)/artifact

$(WORKDIR_TEST)/artifact:
	@mkdir -p $(dir $@)
	@touch $@

ifdef bowerbird::test::suite
$(call bowerbird::test::suite,mock-workdir-test-suite,test,test*,mock-workdir-test-artifact)
endif
endif


test-workdir-deps:
	$(MAKE) -j1 \
		TEST_WORKDIR_DEPS=true \
		WORKDIR_DEPS=$(WORKDIR_TEST)/$@/deps \
		mock-workdir-deps 2>/dev/null
	test -d $(WORKDIR_TEST)/$@/deps/bowerbird-test

ifdef TEST_WORKDIR_DEPS
.PHONY: mock-workdir-deps
mock-workdir-deps:
	$(MAKE) help
endif


test-workdir-build:
	$(MAKE) -j1 \
		TEST_WORKDIR_BUILD=true \
		WORKDIR_BUILD=$(WORKDIR_TEST)/$@/build \
		mock-workdir-build 2>/dev/null
	test -d $(WORKDIR_TEST)/$@/build/help

ifdef TEST_WORKDIR_BUILD
.PHONY: mock-workdir-build
mock-workdir-build:
	$(MAKE) help WORKDIR_BUILD=$(WORKDIR_BUILD)
endif


test-workdir-root:
	$(MAKE) -j1 \
		TEST_WORKDIR_ROOT=true \
		WORKDIR_ROOT=$(WORKDIR_TEST)/$@/root \
		mock-workdir-root 2>/dev/null
	test -d $(WORKDIR_TEST)/$@/root/build
	test -d $(WORKDIR_TEST)/$@/root/deps

ifdef TEST_WORKDIR_ROOT
.PHONY: mock-workdir-root
mock-workdir-root:
	$(MAKE) help
endif




