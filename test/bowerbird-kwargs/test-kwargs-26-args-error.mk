# Tests for bowerbird::core::kwargs-* with 26 arguments (exceeds limit)
#
# Tests that the kwargs parser silently ignores the 26th argument when the limit is 25.
# The 26th argument (z=26) should not be parsed.

test-kwargs-parser-26-args-exceeds-limit:
ifndef TEST_KWARGS_PARSER_26_ARGS_EXCEEDS_LIMIT
	@$(MAKE) TEST_KWARGS_PARSER_26_ARGS_EXCEEDS_LIMIT=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_26_ARGS_A),1)
	$(call bowerbird::test::compare-strings,$(__TEST_26_ARGS_Y),25)
	$(call bowerbird::test::compare-strings,$(__TEST_26_ARGS_Z_DEFINED),)

$(eval $(call bowerbird::core::kwargs-parse,a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8,i=9,j=10,k=11,l=12,m=13,n=14,o=15,p=16,q=17,r=18,s=19,t=20,u=21,v=22,w=23,x=24,y=25,z=26))
$(eval __TEST_26_ARGS_A := $(call bowerbird::core::kwargs,a))
$(eval __TEST_26_ARGS_Y := $(call bowerbird::core::kwargs,y))
$(eval __TEST_26_ARGS_Z_DEFINED := $(call bowerbird::core::kwargs-defined,z))
endif
