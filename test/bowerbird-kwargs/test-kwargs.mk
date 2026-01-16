# Tests for bowerbird::lib::kwargs-* macros
#
# Tests core functionality including parsing, defaults, requires, and corner cases.
# Tests are ordered to incrementally build on each concept.

test-kwargs-parse-basic:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=foo,path=bar) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),foo) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),bar) \
	)


test-kwargs-parse-with-spaces:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name = foo , path = bar) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),foo) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),bar) \
	)


test-kwargs-single-arg:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=single) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),single) \
	)


test-kwargs-many-args:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,a),1) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,h),8) \
	)


test-kwargs-special-chars:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,path=/foo/bar,url=https://example.com,version=1.2.3) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),/foo/bar) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,url),https://example.com) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,version),1.2.3) \
	)


test-kwargs-default-sets-non-empty-string:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,other=value) \
		$(call bowerbird::lib::kwargs-default,name,default-value) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),default-value) \
	)


test-kwargs-default-sets-empty-string:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,other=x) \
		$(call bowerbird::lib::kwargs-default,name,) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),) \
	)


test-kwargs-default-does-not-override-parsed-value:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=foo) \
		$(call bowerbird::lib::kwargs-default,name,default) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),foo) \
	)


test-kwargs-multiple-defaults:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=provided) \
		$(call bowerbird::lib::kwargs-default,name,default1) \
		$(call bowerbird::lib::kwargs-default,path,default2) \
		$(call bowerbird::lib::kwargs-default,url,default3) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,name),provided) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,path),default2) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,url),default3) \
	)


test-kwargs-require-provided:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,required=value) \
		$(call bowerbird::lib::kwargs-require,required) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs,required),value) \
	)


test-kwargs-require-missing:
ifndef TEST_KWARGS_REQUIRE_MISSING
	@$(MAKE) TEST_KWARGS_REQUIRE_MISSING=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: 'required' keyword is required"
else
	$(eval \
		$(call bowerbird::lib::kwargs-parse,other=value) \
		$(call bowerbird::lib::kwargs-require,required) \
	)
endif


test-kwargs-require-custom-error:
ifndef TEST_KWARGS_REQUIRE_CUSTOM_ERROR
	@$(MAKE) TEST_KWARGS_REQUIRE_CUSTOM_ERROR=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: Custom error message"
else
	$(eval \
		$(call bowerbird::lib::kwargs-parse,other=value) \
		$(call bowerbird::lib::kwargs-require,required,ERROR: Custom error message) \
	)
endif


test-kwargs-defined-true:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,name=foo) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs-defined,name),name) \
	)


test-kwargs-defined-false:
	$(eval \
		$(call bowerbird::lib::kwargs-parse,other=value) \
		$(call bowerbird::test::compare-strings,$(call bowerbird::lib::kwargs-defined,name),) \
	)


# Call kwargs-parse at parse-time (outside any recipe) and capture values
$(eval $(call bowerbird::lib::kwargs-parse,global_name=outside,global_path=/tmp))
$(eval __TEST_OUTSIDE_NAME := $(call bowerbird::lib::kwargs,global_name))
$(eval __TEST_OUTSIDE_PATH := $(call bowerbird::lib::kwargs,global_path))

test-kwargs-outside-recipe:
	$(call bowerbird::test::compare-strings,$(__TEST_OUTSIDE_NAME),outside)
	$(call bowerbird::test::compare-strings,$(__TEST_OUTSIDE_PATH),/tmp)
