# Tests for bowerbird::core::kwargs-* argument limits
#
# Tests use __BOWERBIRD_LIB_KWARGS_ARG_NUMS and __BOWERBIRD_LIB_KWARGS_ARGS_LIMIT
# to dynamically test the maximum supported arguments.

ifdef TEST_KWARGS_ARGS_BELOW_LIMIT
$(foreach n,$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS),\
$(eval __BOWERBIRD_LIB_KWARGS_VALUE.var$n := $n))
endif

test-kwargs-args-below-limit:
ifndef TEST_KWARGS_ARGS_BELOW_LIMIT
	@$(MAKE) TEST_KWARGS_ARGS_BELOW_LIMIT=true $(MAKECMDGOALS) 2>&1
else
	@$(foreach n,$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS),$(call \
bowerbird::test::compare-strings,$(call \
bowerbird::core::kwargs,var$n),$n);)true
endif


ifdef TEST_KWARGS_ARGS_AT_LIMIT_FAILS
$(foreach n,\
$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS) $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT),\
$(eval __BOWERBIRD_LIB_KWARGS_VALUE.var$n := $n))
$(if $(filter $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT),\
$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS) $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT)),\
$(error ERROR: Too many arguments \
(maximum $(words $(__BOWERBIRD_LIB_KWARGS_ARG_NUMS)) supported)))
endif

test-kwargs-args-at-limit-fails:
ifndef TEST_KWARGS_ARGS_AT_LIMIT_FAILS
	@! $(MAKE) TEST_KWARGS_ARGS_AT_LIMIT_FAILS=true $(MAKECMDGOALS) 2>&1
else
	@true
endif


ifdef TEST_KWARGS_ARGS_AT_LIMIT_ERROR_MESSAGE
$(foreach n,\
$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS) $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT),\
$(eval __BOWERBIRD_LIB_KWARGS_VALUE.var$n := $n))
$(if $(filter $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT),\
$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS) $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT)),\
$(error ERROR: Too many arguments \
(maximum $(words $(__BOWERBIRD_LIB_KWARGS_ARG_NUMS)) supported)))
endif

test-kwargs-args-at-limit-error-message:
ifndef TEST_KWARGS_ARGS_AT_LIMIT_ERROR_MESSAGE
	@$(MAKE) TEST_KWARGS_ARGS_AT_LIMIT_ERROR_MESSAGE=true \
$(MAKECMDGOALS) 2>&1 | \
grep -q "ERROR: Too many arguments \
(maximum $(words $(__BOWERBIRD_LIB_KWARGS_ARG_NUMS)) supported)"
else
	@true
endif
