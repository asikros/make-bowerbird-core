# Tests for bowerbird::core::kwargs-* macros (parse-time context)
#
# Tests kwargs functionality when called at parse-time (outside recipes).
# Each test uses recursive make to isolate parse-time execution.


test-kwargs-parser-args-single:
ifndef TEST_KWARGS_PARSER_ARGS_SINGLE
	@$(MAKE) TEST_KWARGS_PARSER_ARGS_SINGLE=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_ARGS_SINGLE_NAME),single)

$(eval $(call bowerbird::core::kwargs-parse,name=single))
$(eval __TEST_PARSER_ARGS_SINGLE_NAME := $(call bowerbird::core::kwargs,name))
endif


test-kwargs-parser-args-many:
ifndef TEST_KWARGS_PARSER_ARGS_MANY
	@$(MAKE) TEST_KWARGS_PARSER_ARGS_MANY=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_ARGS_MANY_NAME),foo)
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_ARGS_MANY_PATH),bar)

$(eval $(call bowerbird::core::kwargs-parse,name=foo,path=bar))
$(eval __TEST_PARSER_ARGS_MANY_NAME := $(call bowerbird::core::kwargs,name))
$(eval __TEST_PARSER_ARGS_MANY_PATH := $(call bowerbird::core::kwargs,path))
endif


test-kwargs-parser-parse-args-none:
ifndef TEST_KWARGS_PARSER_PARSE_ARGS_NONE
	@$(MAKE) TEST_KWARGS_PARSER_PARSE_ARGS_NONE=true $(MAKECMDGOALS) 2>&1
else
	@echo "Parse with no args succeeded"

$(eval $(call bowerbird::core::kwargs-parse))
endif


test-kwargs-parser-parse-args-with-spaces:
ifndef TEST_KWARGS_PARSER_PARSE_ARGS_WITH_SPACES
	@$(MAKE) TEST_KWARGS_PARSER_PARSE_ARGS_WITH_SPACES=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_SPACES_NAME),foo)
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_SPACES_PATH),bar)

$(eval $(call bowerbird::core::kwargs-parse,name = foo , path = bar))
$(eval __TEST_PARSER_SPACES_NAME := $(call bowerbird::core::kwargs,name))
$(eval __TEST_PARSER_SPACES_PATH := $(call bowerbird::core::kwargs,path))
endif


test-kwargs-parser-parse-args-with-special-chars:
ifndef TEST_KWARGS_PARSER_PARSE_ARGS_WITH_SPECIAL_CHARS
	@$(MAKE) TEST_KWARGS_PARSER_PARSE_ARGS_WITH_SPECIAL_CHARS=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_SPECIAL_PATH),/foo/bar)
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_SPECIAL_URL),https://example.com)
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_SPECIAL_VERSION),1.2.3)

$(eval $(call bowerbird::core::kwargs-parse,path=/foo/bar,url=https://example.com,version=1.2.3))
$(eval __TEST_PARSER_SPECIAL_PATH := $(call bowerbird::core::kwargs,path))
$(eval __TEST_PARSER_SPECIAL_URL := $(call bowerbird::core::kwargs,url))
$(eval __TEST_PARSER_SPECIAL_VERSION := $(call bowerbird::core::kwargs,version))
endif


test-kwargs-parser-default-non-empty-string:
ifndef TEST_KWARGS_PARSER_DEFAULT_NON_EMPTY_STRING
	@$(MAKE) TEST_KWARGS_PARSER_DEFAULT_NON_EMPTY_STRING=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFAULT_NON_EMPTY_NAME),default)

$(eval $(call bowerbird::core::kwargs-parse))
$(eval $(call bowerbird::core::kwargs-default,name,default))
$(eval __TEST_PARSER_DEFAULT_NON_EMPTY_NAME := $(call bowerbird::core::kwargs,name))
endif


test-kwargs-parser-default-empty-string:
ifndef TEST_KWARGS_PARSER_DEFAULT_EMPTY_STRING
	@$(MAKE) TEST_KWARGS_PARSER_DEFAULT_EMPTY_STRING=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFAULT_EMPTY_NAME),)

$(eval $(call bowerbird::core::kwargs-parse))
$(eval $(call bowerbird::core::kwargs-default,name,))
$(eval __TEST_PARSER_DEFAULT_EMPTY_NAME := $(call bowerbird::core::kwargs,name))
endif


test-kwargs-parser-default-unused:
ifndef TEST_KWARGS_PARSER_DEFAULT_UNUSED
	@$(MAKE) TEST_KWARGS_PARSER_DEFAULT_UNUSED=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFAULT_UNUSED_NAME),foo)

$(eval $(call bowerbird::core::kwargs-parse,name=foo))
$(eval $(call bowerbird::core::kwargs-default,name,default))
$(eval __TEST_PARSER_DEFAULT_UNUSED_NAME := $(call bowerbird::core::kwargs,name))
endif


test-kwargs-parser-default-multiple:
ifndef TEST_KWARGS_PARSER_DEFAULT_MULTIPLE
	@$(MAKE) TEST_KWARGS_PARSER_DEFAULT_MULTIPLE=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFAULT_MULTIPLE_ALPHA),beta)
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFAULT_MULTIPLE_GAMMA),delta)

$(eval $(call bowerbird::core::kwargs-parse))
$(eval $(call bowerbird::core::kwargs-default,alpha,beta))
$(eval $(call bowerbird::core::kwargs-default,gamma,delta))
$(eval __TEST_PARSER_DEFAULT_MULTIPLE_ALPHA := $(call bowerbird::core::kwargs,alpha))
$(eval __TEST_PARSER_DEFAULT_MULTIPLE_GAMMA := $(call bowerbird::core::kwargs,gamma))
endif


test-kwargs-parser-require-provided:
ifndef TEST_KWARGS_PARSER_REQUIRE_PROVIDED
	@$(MAKE) TEST_KWARGS_PARSER_REQUIRE_PROVIDED=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_REQUIRE_PROVIDED_REQUIRED),value)

$(eval $(call bowerbird::core::kwargs-parse,required=value))
$(eval $(call bowerbird::core::kwargs-require,required))
$(eval __TEST_PARSER_REQUIRE_PROVIDED_REQUIRED := $(call bowerbird::core::kwargs,required))
endif


test-kwargs-parser-require-missing:
ifndef TEST_KWARGS_PARSER_REQUIRE_MISSING
	@$(MAKE) TEST_KWARGS_PARSER_REQUIRE_MISSING=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: 'required' keyword is required"
else
$(eval $(call bowerbird::core::kwargs-parse))
$(eval $(call bowerbird::core::kwargs-require,required))
endif


test-kwargs-parser-require-custom-error:
ifndef TEST_KWARGS_PARSER_REQUIRE_CUSTOM_ERROR
	@$(MAKE) TEST_KWARGS_PARSER_REQUIRE_CUSTOM_ERROR=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: Custom error message"
else
$(eval $(call bowerbird::core::kwargs-parse))
$(eval $(call bowerbird::core::kwargs-require,required,ERROR: Custom error message))
endif


test-kwargs-parser-defined-true:
ifndef TEST_KWARGS_PARSER_DEFINED_TRUE
	@$(MAKE) TEST_KWARGS_PARSER_DEFINED_TRUE=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFINED_TRUE_RESULT),name)

$(eval $(call bowerbird::core::kwargs-parse,name=foo))
$(eval __TEST_PARSER_DEFINED_TRUE_RESULT := $(call bowerbird::core::kwargs-defined,name))
endif


test-kwargs-parser-defined-false:
ifndef TEST_KWARGS_PARSER_DEFINED_FALSE
	@$(MAKE) TEST_KWARGS_PARSER_DEFINED_FALSE=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_DEFINED_FALSE_RESULT),)

$(eval $(call bowerbird::core::kwargs-parse,other=value))
$(eval __TEST_PARSER_DEFINED_FALSE_RESULT := $(call bowerbird::core::kwargs-defined,name))
endif


test-kwargs-parser-nested:
ifndef TEST_KWARGS_PARSER_NESTED
	@$(MAKE) TEST_KWARGS_PARSER_NESTED=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_NESTED_NAME),alpha)
	$(call bowerbird::test::compare-strings,$(__TEST_PARSER_NESTED_PATH),beta)

define mock-kwargs-parser-nested
$(call bowerbird::core::kwargs-parse,name=alpha)
$(call bowerbird::core::kwargs-default,path,beta)
$(eval __TEST_PARSER_NESTED_NAME := $(call bowerbird::core::kwargs,name))
$(eval __TEST_PARSER_NESTED_PATH := $(call bowerbird::core::kwargs,path))
endef

$(eval $(call mock-kwargs-parser-nested))
endif
