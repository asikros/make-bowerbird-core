# Tests for bowerbird::core::kwargs-* macros (recipe context)
#
# Tests kwargs functionality when called within recipe blocks using $(eval ...).
# Tests are ordered to incrementally build on each concept.


test-kwargs-recipe-args-single:
	$(eval $(call bowerbird::core::kwargs-parse,name=single))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),single)


test-kwargs-recipe-args-many:
	$(eval $(call bowerbird::core::kwargs-parse,name=foo,path=bar))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),foo)
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,path),bar)


test-kwargs-recipe-parse-args-none:
	$(eval $(call bowerbird::core::kwargs-parse))


test-kwargs-recipe-parse-args-with-spaces:
	$(eval $(call bowerbird::core::kwargs-parse,name = foo , path = bar))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),foo)
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,path),bar)


test-kwargs-recipe-parse-args-with-special-chars:
	$(eval $(call bowerbird::core::kwargs-parse,path=/foo/bar,url=https://example.com,version=1.2.3))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,path),/foo/bar)
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,url),https://example.com)
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,version),1.2.3)


test-kwargs-recipe-default-non-empty-string:
	$(eval $(call bowerbird::core::kwargs-parse))
	$(eval $(call bowerbird::core::kwargs-default,name,default))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),default)


test-kwargs-recipe-default-empty-string:
	$(eval $(call bowerbird::core::kwargs-parse))
	$(eval $(call bowerbird::core::kwargs-default,name,))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),)


test-kwargs-recipe-default-unused:
	$(eval $(call bowerbird::core::kwargs-parse,name=foo))
	$(eval $(call bowerbird::core::kwargs-default,name,default))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),foo)


test-kwargs-recipe-default-multiple:
	$(eval $(call bowerbird::core::kwargs-parse))
	$(eval $(call bowerbird::core::kwargs-default,alpha,beta))
	$(eval $(call bowerbird::core::kwargs-default,gamma,delta))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,alpha),beta)
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,gamma),delta)


test-kwargs-recipe-require-provided:
	$(eval $(call bowerbird::core::kwargs-parse,required=value))
	$(eval $(call bowerbird::core::kwargs-require,required))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,required),value)


test-kwargs-recipe-require-missing:
ifndef TEST_KWARGS_RECIPE_REQUIRE_MISSING
	@$(MAKE) TEST_KWARGS_RECIPE_REQUIRE_MISSING=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: 'required' keyword is required"
else
	$(eval $(call bowerbird::core::kwargs-parse))
	$(eval $(call bowerbird::core::kwargs-require,required))
endif


test-kwargs-recipe-require-custom-error:
ifndef TEST_KWARGS_RECIPE_REQUIRE_CUSTOM_ERROR
	@$(MAKE) TEST_KWARGS_RECIPE_REQUIRE_CUSTOM_ERROR=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: Custom error message"
else
	$(eval $(call bowerbird::core::kwargs-parse))
	$(eval $(call bowerbird::core::kwargs-require,required,ERROR: Custom error message))
endif


test-kwargs-recipe-defined-true:
	$(eval $(call bowerbird::core::kwargs-parse,name=foo))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs-defined,name),name)


test-kwargs-recipe-defined-false:
	$(eval $(call bowerbird::core::kwargs-parse,other=value))
	$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs-defined,name),)

test-kwargs-recipe-nested:
ifndef TEST_KWARGS_RECIPE_NESTED
	@$(MAKE) TEST_KWARGS_RECIPE_NESTED=true $(MAKECMDGOALS) 2>&1
else
	$(call mock-kwargs-recipe-nested)


define mock-kwargs-recipe-nested
$(eval $(call bowerbird::core::kwargs-parse,name=alpha))
$(eval $(call bowerbird::core::kwargs-default,path,beta))
$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,name),alpha)
$(call bowerbird::test::compare-strings,$(call bowerbird::core::kwargs,path),beta)
endef
endif
