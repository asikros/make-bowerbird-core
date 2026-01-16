# Tests for kwargs system integrity - value isolation between calls
#
# These tests verify that values from previous kwargs-parse calls do not leak
# into subsequent calls. This is critical for correctness - if values leak,
# macros that use kwargs may receive stale/incorrect parameters.

test-kwargs-no-leak-sequential:
	@# First call: set name=first, path=leaked, url=old
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=first,path=leaked,url=old) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),first) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),leaked) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,url),old) \
	)
	@# Second call: only set name=second (path and url NOT passed)
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=second) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),second) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,url),) \
	)


test-kwargs-no-leak-via-getter:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=first,path=leaked) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),leaked) \
	)
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=second) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),) \
	)


test-kwargs-no-leak-via-defined:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=first,path=leaked) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs-defined,path),path) \
	)
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=second) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs-defined,path),) \
	)
