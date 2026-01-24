# Tests for bowerbird::core::kwargs-* argument limits
#
# Tests the maximum supported arguments (25) and error when exceeding the limit (26).

test-kwargs-args-25-args:
ifndef TEST_KWARGS_ARGS_25_ARGS
	@$(MAKE) TEST_KWARGS_ARGS_25_ARGS=true $(MAKECMDGOALS) 2>&1
else
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_A),1)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_B),2)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_C),3)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_D),4)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_E),5)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_F),6)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_G),7)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_H),8)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_I),9)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_J),10)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_K),11)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_L),12)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_M),13)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_N),14)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_O),15)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_P),16)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_Q),17)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_R),18)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_S),19)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_T),20)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_U),21)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_V),22)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_W),23)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_X),24)
	$(call bowerbird::test::compare-strings,$(__TEST_25_ARGS_Y),25)

$(eval $(call bowerbird::core::kwargs-parse,a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8,i=9,j=10,k=11,l=12,m=13,n=14,o=15,p=16,q=17,r=18,s=19,t=20,u=21,v=22,w=23,x=24,y=25))
$(eval __TEST_25_ARGS_A := $(call bowerbird::core::kwargs,a))
$(eval __TEST_25_ARGS_B := $(call bowerbird::core::kwargs,b))
$(eval __TEST_25_ARGS_C := $(call bowerbird::core::kwargs,c))
$(eval __TEST_25_ARGS_D := $(call bowerbird::core::kwargs,d))
$(eval __TEST_25_ARGS_E := $(call bowerbird::core::kwargs,e))
$(eval __TEST_25_ARGS_F := $(call bowerbird::core::kwargs,f))
$(eval __TEST_25_ARGS_G := $(call bowerbird::core::kwargs,g))
$(eval __TEST_25_ARGS_H := $(call bowerbird::core::kwargs,h))
$(eval __TEST_25_ARGS_I := $(call bowerbird::core::kwargs,i))
$(eval __TEST_25_ARGS_J := $(call bowerbird::core::kwargs,j))
$(eval __TEST_25_ARGS_K := $(call bowerbird::core::kwargs,k))
$(eval __TEST_25_ARGS_L := $(call bowerbird::core::kwargs,l))
$(eval __TEST_25_ARGS_M := $(call bowerbird::core::kwargs,m))
$(eval __TEST_25_ARGS_N := $(call bowerbird::core::kwargs,n))
$(eval __TEST_25_ARGS_O := $(call bowerbird::core::kwargs,o))
$(eval __TEST_25_ARGS_P := $(call bowerbird::core::kwargs,p))
$(eval __TEST_25_ARGS_Q := $(call bowerbird::core::kwargs,q))
$(eval __TEST_25_ARGS_R := $(call bowerbird::core::kwargs,r))
$(eval __TEST_25_ARGS_S := $(call bowerbird::core::kwargs,s))
$(eval __TEST_25_ARGS_T := $(call bowerbird::core::kwargs,t))
$(eval __TEST_25_ARGS_U := $(call bowerbird::core::kwargs,u))
$(eval __TEST_25_ARGS_V := $(call bowerbird::core::kwargs,v))
$(eval __TEST_25_ARGS_W := $(call bowerbird::core::kwargs,w))
$(eval __TEST_25_ARGS_X := $(call bowerbird::core::kwargs,x))
$(eval __TEST_25_ARGS_Y := $(call bowerbird::core::kwargs,y))
endif


test-kwargs-args-26-args-exceeds-limit:
ifndef TEST_KWARGS_ARGS_26_ARGS_EXCEEDS_LIMIT
	@$(MAKE) TEST_KWARGS_ARGS_26_ARGS_EXCEEDS_LIMIT=true $(MAKECMDGOALS) 2>&1 | \
		grep -q "ERROR: Too many arguments (maximum 25 supported)"
else
$(eval $(call bowerbird::core::kwargs-parse,a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8,i=9,j=10,k=11,l=12,m=13,n=14,o=15,p=16,q=17,r=18,s=19,t=20,u=21,v=22,w=23,x=24,y=25,z=26))
endif
